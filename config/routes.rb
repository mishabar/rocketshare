Rocketshare::Application.routes.draw do
  match 'share' => 'share#share'
  match 'leaderboard/:fb_id' => 'share#leaderboard'
  match 'my/:fb_id' => 'share#my_place'
  match 'stats/:fb_id' => 'share#stats'
  match 'share/add/:fb_id/:link' => 'share#add_share'
  match 'bonus/add/:fb_id/:miles' => 'share#add_bonus'
  match 'reports' => 'reports#default'
  match ':short_url' => 'share#generate'

  root :controller => 'share', :action => 'redirect_to_google_play'
end
