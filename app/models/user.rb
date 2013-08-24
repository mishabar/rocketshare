class User < ActiveRecord::Base

  has_many :shared_links
end
