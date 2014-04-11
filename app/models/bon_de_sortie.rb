# encoding: utf-8
class BonDeSortie
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds, autosave: true
  belongs_to :destination
  #attr_accessible :id, :_id
  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}BDS#{"%04d" % BonDeSortie.count}" }
  field :poids, type: Float
  field :codedr_cadre2, type: String
  field :codedr_cadre12, type: String
  field :denomination_id, type: Integer

  attr_accessible :poids, :codedr_cadre12, :codedr_cadre2, :denomination_id
end
