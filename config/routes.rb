Rocketshare::Application.routes.draw do
  match 'share' => 'share#share'
  match 'leaderboard/:fb_id' => 'share#leaderboard'
  match 'stats/:fb_id' => 'share#stats'
  match 'share/add/:fb_id/:link' => 'shares#add_share'
  match 'bonus/add/:fb_id/:miles' => 'shares#add_bonus'
  match 'reports' => 'reports#default'
  match ':short_url' => 'share#generate'
end
