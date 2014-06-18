# encoding: utf-8
class Produit # < ActiveRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds, autosave: false
  has_many :bon_de_sortie, autosave: true

  attr_accessible :id, :nom, :references, :mention, :consistance, :code_dr_reception, :code_dr_expedition, :is_ecodds, :brigitte, :code_rubrique, :seuil_alerte, :is_ddi, :is_ddm, :classe
  validates_presence_of :is_ecodds, :nom, :mention, :consistance, :code_dr_expedition, :code_dr_reception, :references, :seuil_alerte, :is_ddi, :is_ddm, :classe

  field :is_ecodds, type: Boolean, default: false
  field :nom, type: String
  field :references, type: Array
  field :mention, type: String
  field :consistance, type: Integer
  field :classe, type: String
  field :index, type: Integer, default: ->{ Produit.count + 1 }
  field :brigitte, type: String, default: ""
  field :code_dr_reception, type: String
  field :code_dr_expedition, type: String
  field :code_rubrique, type: String
  field :seuil_alerte, type: Float
  field :is_ddm, type: Boolean, default: false
  field :is_ddi, type: Boolean, default: false

  def type
    s = "<label class='label label-%s'>%s</label>"
    type = []
    type << s % ["success", "DDI"] if is_ddi
    type << s % ["warning", "DDM"] if is_ddm
    type << s % ["primary", "ECODDS"] if is_ecodds
    type << s % ["default", "normal"] if type.empty?
    type.join("&nbsp;")
  end
  def consistance_to_human
    case consistance
    when 0
      "Solide"
    when 1
      "Liquide"
    when 2
      "Gazeux"
    end
  end
  def ecodds
    if is_ecodds
      "<span class=\"label label-success\">EcoDDS</span>"
    else
      "<span class=\"label label-info\">Non EcoDDS</span>"
    end
  end
  def self.to_select
    Produit.asc(:index, 1).reduce([]) do | ary, p |
      ary << [p.nom, p.index ]
      ary
    end
  end
  def self.to_nomenclature
    Produit.asc(:index, 1).map { |r| [ r.mention, r.id ] }
  end
  def self.to_ecodds_data
    Produit.where(is_ecodds: true).asc(:index, 1).map { |r| {id: r.id, label: r.nom, cr: r.code_rubrique, dr11: r.code_dr_reception, dr12: r.code_dr_expedition, dest: r.references.first, c6tnc: r.consistance, un: r.mention } if r.is_ecodds }.compact
  end
  def self.to_data
    Produit.asc(:index, 1).map { |r| {id: r.id, label: r.nom, cr: r.code_rubrique, dr11: r.code_dr_reception, dr12: r.code_dr_expedition, dest: r.references.first, c6tnc: r.consistance, un: r.mention } }
  end

  def self.to_destinations
    Produit.asc(:index, 1).reduce([]) do | a, p |
      a << {id: p.references.first, text: p.references.first } if p.references.any? && !(a.map{|c| c[:text]}.include?(p.references.first) || p.references.first.blank?)
      a
    end
  end
  def denomination_ecodds
    "#{"%02d" % index}-#{nom}"
  end

end
