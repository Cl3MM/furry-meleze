class Collecteur < Company

  has_many :ebsdds

  field :recepisse, type: String
  field :mode_transport, type: Integer#, default: 1
  field :limite_validite, type: Date

  validates_presence_of :recepisse, :limite_validite, :mode_transport

  attr_accessible :recepisse, :mode_transport, :limite_validite

end
