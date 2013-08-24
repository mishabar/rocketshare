require 'uri'
require 'mechanize'

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
      if params[:fb_id].blank?
        data[:error] = 'Invalid or missing fb_id'
      elsif params[:name].blank?
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

        short_link = "#{user.fb_id}:#{params[:url]}".to_i(32)
        unless SharedLink.exists?({:short_link => short_link.to_s})
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

            @link.save
          end

          data[:link] = @link
        end
      end
    rescue Exception => ex
      data[:error] = 'Unexpected error'
      data[:error_details] = ex.message
    end

    render :json => data
  end

  def generate
    @web_flow = true
    if request.env['HTTP_USER_AGENT'].include?('(+https://www.facebook.com/externalhit_uatext.php)') || # Facebook External Crawler
        request.env['HTTP_USER_AGENT'].include?('Google (+https://developers.google.com/+/web/snippet/)') # Google+ snippet
      @web_flow = false
    end
    @link = SharedLink.find_by_short_link(params[:short_url])

    #if web_flow
    #  request.env['HTTP_REFERER'] = 'http://www.rockt.com'
    #  redirect_to @link.original_link
    #end
  end

  private

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
