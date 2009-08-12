class Player < ActiveRecord::Base
  
  validates_presence_of :name, :birthday 
  validates_uniqueness_of :url_id
  
  has_many :contracts, :order => 'start_year ASC'
  has_many :clubs, :through => :contracts

  belongs_to :url

  def get_birth_place
    if(birth_country)
      if(birth_city)
        "in #{birth_city}, #{birth_country}"
      else
        "in #{birth_country}"
      end
    end
  end

  def to_s
    if(given_name!=name)
      "Player: #{given_name} called #{name} born #{birthday}"
    else
      "Player: #{given_name} born #{birthday}"
    end
    
    contracts.each do |contract|
      contract.to_s
    end
    
  end
end
