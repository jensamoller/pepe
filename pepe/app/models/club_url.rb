class ClubUrl < ActiveRecord::Base
  
  validates_uniqueness_of :url_id
  belongs_to :url
  belongs_to :club  
  
end
