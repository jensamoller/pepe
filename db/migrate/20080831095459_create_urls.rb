class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.column :url, :string, :null => false, :unique => true
      t.column :visited, :timestamp
      t.column :depth, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :urls
  end
end
