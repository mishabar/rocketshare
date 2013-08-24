class SharedLink < ActiveRecord::Base

  serialize :images, Array
  serialize :og_images, Array

  belongs_to :user
end
