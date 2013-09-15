class Leaderboard < ActiveRecord::Base
  set_table_name 'leaderboard'

  attr_accessible :fb_id, :user_id, :shares, :views, :miles

  belongs_to :user

  def self.rebuild
    sql = 'INSERT INTO leaderboard (user_id, fb_id, shares, views, miles, created_at, updated_at)
           SELECT 	u.id as user_id, u.fb_id, coalesce(o1.shares, 0) as shares, coalesce(o2.views, 0) as views,
                    (coalesce(o1.shares, 0) * 5 + coalesce(o2.views, 0) * 10) as miles,
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
           FROM 	users u
           LEFT JOIN
             (SELECT 	user_id, fb_id, COUNT(1) as shares
             FROM 	shared_links
             GROUP BY user_id, fb_id) o1 ON u.id = o1.user_id
           LEFT JOIN
             (SELECT 	user_id, fb_id, SUM(views) as views
             FROM 	stats s
             INNER JOIN users u ON u.id = s.user_id
             GROUP BY s.user_id, u.fb_id) o2 ON u.id = o2.user_id'

    ActiveRecord::Base.establish_connection()
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.for_user(fb_id)
    top_users = Leaderboard.joins(:user).select('user_id, users.fb_id, users.name, shares, views, miles').order('miles desc, views desc, shares desc').limit(100)
    my_score = Leaderboard.where({:fb_id => fb_id}).first
    my_place = Leaderboard.where('miles > ?', my_score.miles).select('(COUNT(1) + 1) as place').first
    return { :leaderboard => top_users, :me => {:user_id => my_score.user_id, :fb_id => my_score.fb_id,
                                                :name => my_score.user.name,
                                                :shares => my_score.shares, :views => my_score.views,
                                                :miles => my_score.miles, :place => my_place['place']}}
  end
end