class CreateUnparsableUrls < ActiveRecord::Migration
  def self.up
    create_table :unparsable_urls do |t|
      t.column :url, :string, :null => false, :unique => true
      t.column :visited, :timestamp
      t.timestamps
    end
  end

  def self.down
    drop_table :unparsable_urls
  end
end
