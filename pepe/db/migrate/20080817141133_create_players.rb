class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.string  :given_name
      t.string  :name
      t.date    :birthday, :default => "1975-10-30"
      t.integer :height, :null => true, :default => 0
      t.integer :jersey_number, :null => true, :default => 0
      t.integer :url_id, :null => false, :unique => true
      t.string  :birth_country
      t.string  :birth_city
      t.string  :image_url
      t.text   :wikipedia_info
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
