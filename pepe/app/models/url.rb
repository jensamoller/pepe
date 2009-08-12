class Url < ActiveRecord::Base
  
  validates_uniqueness_of :url
    
  def to_s
    "URL: #{url} @#{depth} #{visited}"
  end
end
