class Contract < ActiveRecord::Base
  
  belongs_to :player
  belongs_to :club
  
  ContractTypes = {
    :player => "Player", 
    :player_on_loan => "Player on loan", 
    :manager =>"Manager"
  }

  validates_inclusion_of :contract_type, :in => ContractTypes.values
  
  def to_s
    if(end_year)
      "#{player.given_name} has played #{apperances} games in #{club.full_name} from #{start_year} to #{end_year} as a #{contract_type} scoring #{goals} times"
    else
      "#{player.given_name} has played #{apperances} games in #{club.full_name} from #{start_year} as a #{contract_type} scoring #{goals} times"
    end
  end
  
end
