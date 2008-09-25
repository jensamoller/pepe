class Club < ActiveRecord::Base
  
  validates_uniqueness_of :url_id

  has_many :contracts
  has_many :players, :through => :contracts
  

  belongs_to :url

  def to_s
    "Club: #{full_name} #{founded}"
  end

end
