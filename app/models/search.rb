class Search
  include Mongoid::Document
  include Mongoid::Timestamps
  field :date_min, type: Date
  field :date_max, type: Date
  field :date, type: Date
  field :producteur_nom, type: String
  field :producteur_siret, type: String
  field :producteur_responsable, type: String
  field :producteur_ville, type: String
  field :producteur_cp, type: String
  field :status, type: String
  field :nomenclature, type: String
  field :poids_min, type: Float
  field :poids_max, type: Float
end
