class CreateClubUrls < ActiveRecord::Migration
  def self.up
    create_table :club_urls do |t|
      t.integer :url_id, :null => false
      t.integer :club_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :club_urls
  end
end