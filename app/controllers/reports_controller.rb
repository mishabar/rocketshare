class ReportsController < ApplicationController
  layout 'report'

  def default
    select = 'DATE(created_at) as row_date, SUM(stats.ios) as ios, SUM(stats.android) as android, SUM(stats.other_os) as other_os, SUM(facebook) as facebook, SUM(twitter) as twitter, SUM(googleplus) as googleplus, SUM(other_sn) as other_sn,  SUM(stats.views) as views'
    @views = Stat.where(:date => 7.days.ago.utc.beginning_of_day..Time.now.utc).group('DATE(created_at)').select(select).index_by { |t| t.row_date }
    @shares = SharedLink.where(:created_at => 7.days.ago.utc.beginning_of_day..Time.now.utc).group('DATE(created_at)').select('DATE(created_at) as row_date, count(shared_links.user_id) as shares').index_by { |t| t.row_date }

    @data = {}
    @views.each do |view|
      @data[view[0]] = {:date => view[0], :ios => view[1].ios, :android => view[1].android, :other_os => view[1].other_os, :facebook => view[1].facebook, :twitter => view[1].twitter, :googleplus => view[1].googleplus, :other_sn => view[1].other_sn, :views => view[1].views, :shares => 0}
    end
    @shares.each do |share|
      if @data[share[0]].nil?
        @data[share[0]] = {:date => share[0], :ios => 0, :android => 0, :other_os => 0, :facebook => 0, :googleplus => 0, :other_sn => 0, :views => 0, :shares => share[1].shares }
      else
        @data[share[0]][:shares] = share[1].shares
      end
    end

    @data = Hash[@data.sort.reverse]
  end
end
