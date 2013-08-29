class Stat < ActiveRecord::Base
  attr_accessible :link_id, :user_id, :date, :hour

  belongs_to :shared_link
  belongs_to :user
end