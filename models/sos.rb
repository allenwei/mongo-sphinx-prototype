class Sos 
  include Mongoid::Document
  self.collection_name = 'sos' 
  field :region_id 
  field :active 
  field :name 
  field :id 
end
