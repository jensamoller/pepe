class CreateClubs < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.string :name
      t.string :full_name
      t.integer :year_founded
      t.string :date_founded
      t.string :country
      # t.integer :url_id, :null => false, :unique => true
      t.string :chairman
      t.string :manager
      t.string :stadium
      t.string :league
      t.string :nickname
      t.string :crest_url
      t.text   :wikipedia_info

      t.timestamps
    end
  end

  def self.down
    drop_table :clubs
  end
end
