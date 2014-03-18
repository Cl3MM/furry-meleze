class Company
  include Mongoid::Document
  include Mongoid::Timestamps

  field :siret, type: String
  field :nom, type: String
  field :adresse, type: String
  field :cp, type: String
  field :ville, type: String
  field :tel, type: String
  field :fax, type: String
  field :email, type: String, default: nil
  field :responsable, type: String
  field :actif, type: Boolean

  attr_accessible :siret, :nom, :adresse, :cp, :ville, :tel, :fax, :email, :responsable
  validates_presence_of :nom #:siret, :responsable, :nom, :cp, :ville, :adresse
end
