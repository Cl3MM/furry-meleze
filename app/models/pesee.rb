class Pesee
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :ebsdd #, class_name: "Ebsdd", inverse_of: :pesees #, inverse_of: :pesees

  attr_accessible :brut, :net, :tare, :dsd, :date, :heure, :nom_tare, :poids_tare#, :ebsdd

  field :brut, type: Float
  field :net, type: Float
  field :tare, type: Float
  field :dsd, type: String
  field :date, type: String
  field :heure, type: String
  field :nom_tare, type: String
  field :poids_tare, type: Float

  def poids_calcule
    brut - tare
  end
end
