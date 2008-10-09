class Club < ActiveRecord::Base
  
  #validates_uniqueness_of :url_id
  validates_presence_of :full_name, :name

  has_many :contracts
  has_many :players, :through => :contracts

  has_many :club_urls
  has_many :urls, :through => :club_urls

  def to_s
    "Club: #{full_name} #{founded}"
  end

end
