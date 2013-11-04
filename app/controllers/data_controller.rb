require 'uri'
require 'mechanize'
require 'nokogiri'
require 'digest/md5'
require 'hpricot'

class DataController < ApplicationController

  def generate
    #  Get page details
    mechanize = Mechanize.new { |agent|
      agent.user_agent = request.env['HTTP_USER_AGENT']
      agent.ssl_version = 'SSLv3'
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    }

    mechanize.get(params[:url]) do |page|
      render :text => page.title
    end
  end
end
