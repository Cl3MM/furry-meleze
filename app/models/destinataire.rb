class Destinataire < Company
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds
end
