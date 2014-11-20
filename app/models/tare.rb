class Tare
  include Mongoid::Document
  validates_numericality_of :poids, greater_than_or_equal_to: 0
  validates_presence_of :nom, :poids
  field :nom, type: String
  field :poids, type: Float
end
