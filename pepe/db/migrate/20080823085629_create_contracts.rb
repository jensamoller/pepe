class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.integer :player_id, :null => false
      t.integer :club_id, :null => false
      t.integer :start_year
      t.integer :end_year
      t.string :contract_type, :null => false
      t.integer :apperances
      t.integer :goals
      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
