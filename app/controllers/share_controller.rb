require 'uri'
require 'mechanize'
require 'nokogiri'
require 'digest/md5'
require 'hpricot'

class ShareController < ApplicationController

  # Open Graph tags
  OG_TITLE = 'og:title'
  OG_DESCRIPTION = 'og:description'
  OG_IMAGE = 'og:image'
  OG_IMAGE_SECURE = 'og:image:secure_url'

  # Google+ tags


  def share
    data = {}
    begin
      #  Check required parameters
      puts params[:fb_id]
      puts params[:name]
      puts params[:url]
      if params[:fb_id].blank?
        data[:error] = 'Invalid or missing fb_id'
      elsif params[:name].blank? && User.find_by_fb_id(params[:fb_id]).nil?
        data[:error] = 'Invalid or missing name'
      elsif params[:url].blank? || !valid?(params[:url])
        data[:error] = 'Invalid or missing url'
      else
        #  Get user details
        user = User.find_or_initialize_by_fb_id(params[:fb_id])
        if user.new_record?
          user.name = params[:name]
          user.email = params[:email] unless params[:email].blank?
          user.save
        end

        links = SharedLink.where({:fb_id => params[:fb_id], :original_link => params[:url]})

        if links.count == 0
          short_link = SecureRandom.urlsafe_base64(6)
          while SharedLink.exists?({:short_link => short_link})
            short_link = SecureRandom.urlsafe_base64(6)
          end

          #  Get page details
          mechanize = Mechanize.new { |agent|
            agent.user_agent = request.env['HTTP_USER_AGENT']
            agent.ssl_version = 'SSLv3'
            agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
          }

          mechanize.get(params[:url]) do |page|
            @link = SharedLink.new()
            @link.user_id = user.id
            @link.fb_id = user.fb_id
            @link.original_link = params[:url]
            @link.short_link = short_link.to_s

            # Title
            @link.title = page.title
            @link.og_title = get_open_graph_property_value(page, OG_TITLE, @link.title)

            # Description
            unless page.at('meta[@name="description"]').nil?
              @link.description = page.at('meta[@name="description"]')[:content]
            end
            @link.og_description = get_open_graph_property_value(page, OG_DESCRIPTION, @link.description)
            @link.description = @link.og_description if @link.description.nil?

            # Images
            @link.images = []
            @link.og_images = get_open_graph_property_values(page, OG_IMAGE, @link.images)
            if @link.og_images.length == 0
              @link.images = try_find_images(page)
              @link.og_images = @link.images
            end

            @link.save
          end
        else
          @link = links[0]
        end
        data[:link] = {:url => @link.short_link}
      end
    rescue Exception => ex
      data[:error] = 'Unexpected error'
      data[:error_details] = ex.message
    end

    render :json => data
  end

  def add_share
    link = SharedLink.find_by_short_link(params[:link])
    leaderboard = Leaderboard.find_or_initialize_by_fb_id(link.fb_id)
    if leaderboard.new_record?
      leaderboard.user_id = link.user_id
      leaderboard.views = 0
      leaderboard.shares = 1
      leaderboard.miles = 5
      leaderboard.save
    else
      leaderboard.increment!(:shares)
      leaderboard.increment!(:miles, 5)
    end
    render :json => {:status => 'ok', :miles => 5}
  end

  def add_bonus
    leaderboard = Leaderboard.find_or_initialize_by_fb_id(params[:fb_id])
    if leaderboard.new_record?
      leaderboard.user_id = link.user_id
      leaderboard.views = 0
      leaderboard.shares = 0
      leaderboard.miles = params[:miles].to_i
      leaderboard.save
    else
      leaderboard.increment!(:miles, params[:miles].to_i)
    end

    render :json => {:status => 'ok', :miles => params[:miles].to_i}
  end

  def generate
    @web_flow = params[:debug].nil?
    if request.env['HTTP_USER_AGENT'].include?('(+https://www.facebook.com/externalhit_uatext.php)') || # Facebook External Crawler
        request.env['HTTP_USER_AGENT'].include?('Google (+https://developers.google.com/+/web/snippet/)') # Google+ snippet
      @web_flow = false
    end
    @link = SharedLink.find_by_short_link(params[:short_url])
    if @web_flow == true
      add_view(@link)
    end
    if request.env['HTTP_USER_AGENT'].include?('Mac OS X')
      redirect_to @link.original_link
      return
    end
  end

  def leaderboard
    render :json => Leaderboard.for_user(params[:fb_id], false)
  end

  def my_place
    render :json => Leaderboard.for_user(params[:fb_id], true)
  end

  def stats
    @user = User.find_by_fb_id(params[:fb_id])
    friends = []

    unless params[:friends].nil?
      in_values = (params[:friends].map! { |v| "'#{v}'" }).join(',')
      sql = " SELECT l.fb_id as fb_id, u.name as name, views, shares, miles
              FROM leaderboard l
              INNER JOIN users u ON u.id = l.user_id
              WHERE l.fb_id IN (#{in_values})"

      ActiveRecord::Base.establish_connection()
      results = ActiveRecord::Base.connection().execute(sql)
      results.each do |row|
        friends.push({:fb_id => row['fb_id'], :name => row['name'], :views => row['views'], :shares => row['shares'], :miles => row['miles']})
      end
    end
    my_score = Leaderboard.find_by_fb_id(params[:fb_id])
    render :json => {:me => {:fb_id => my_score.fb_id, :name => @user.name,
                             :views => my_score.views, :shares => my_score.shares, :miles => my_score.miles},
                     :friends => friends}
  end

  def redirect_to_google_play
    redirect_to 'https://play.google.com/store/apps/details?id=com.rocketshare'
  end

  def delete_user
    user = User.find_by_fb_id(params[:fb_id])
    unless user.nil?
      SharedLink.destroy_all(:fb_id => params[:fb_id])
      Leaderboard.destroy_all(:fb_id => params[:fb_id])
      Stat.destroy_all(:user_id => user.id)
      user.destroy
    end

    render :json => {:fb_id => params[:fb_id]}
  end

  private

  def add_view(link)
    begin
      # Add cookie
      if cookies[link.short_link].nil?
        cookies[link.short_link] = {value: true, expires: 1.day.from_now}

        utc_now = Time.now.utc
        stats = Stat.where({:link_id => link.id, :user_id => link.user_id, :date => Date.parse(utc_now.to_s), :hour => utc_now.hour}).limit(1)
        if stats.count == 0
          stat = Stat.new({:link_id => link.id, :user_id => link.user_id, :date => Date.parse(utc_now.to_s), :hour => utc_now.hour})
          stat.save
        else
          stat = stats[0]
        end
        referrer = @_request.env['HTTP_REFERER']
        puts referrer
        unless referrer.blank?
          # Save stat
          if referrer.downcase.include? 'facebook.com'
            stat.increment!(:facebook)
          elsif referrer.downcase.include? 'google.com/'
            stat.increment!(:googleplus)
          elsif referrer.downcase.include? '/t.co/'
            stat.increment!(:twitter)
          else
            stat.increment!(:other_sn)
          end
          leaderboard = Leaderboard.find_or_initialize_by_fb_id(link.fb_id)
          if leaderboard.new_record?
            leaderboard.user_id = link.user_id
            leaderboard.views = 1
            leaderboard.shares = 0
            leaderboard.miles = 10
            leaderboard.save
          else
            leaderboard.increment!(:views)
            leaderboard.increment!(:miles, 10)
          end

          os = @_request.env['HTTP_USER_AGENT'].downcase
          if !/(ipod|ipad|iphone)/.match(os).nil?
            stat.increment!(:ios)
          elsif !/(android)/.match(os).nil?
            stat.increment!(:android)
          else
            stat.increment!(:other_os)
          end

          stat.increment!(:views)
        end
      end
    rescue Exception => ex
      puts ex.message
    end
  end

  def try_find_images(page)
    images = []
    page.images.each do |img|
      if !img.alt.blank? &&
          (!img.width.nil? && img.width.to_i > 100) &&
          (!img.height.nil? && img.height.to_i > 100)
        images.push(URI.join(page.uri, img.src).to_s)
      end
      if images.length == 3
        break
      end
    end

    return images
  end

  def get_open_graph_property_value(page, name, default)
    tag = page.at("meta[@property='#{name}']")
    if  !tag.nil? && !tag[:content].nil?
      return tag[:content]
    else
      return default
    end
  end

  def get_open_graph_property_values(page, name, default)
    tag = page.at("meta[@property='#{name}']")
    if  !tag.nil? && !tag[:content].nil?
      return [tag[:content]]
    else
      return default
    end
  end

  def valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end
end
