# encoding: utf-8

module Mongoable
  extend ActiveSupport::Concern

  included do
    after_create :set_associations
    after_update :set_associations

    field :nom_producteur, type: String
    field :nom_collecteur, type: String
    field :nom_destinataire, type: String
    field :nom_destination, type: String
    field :nom_produit, type: String

    def self.update_mongoable
      Ebsdd.each do |e|
        e.set :nom_producteur, e.has_producteur? ? e.producteur.nom : nil
        e.set :nom_destinataire, e.has_destinataire? ? e.destinataire.nom : nil
        e.set :nom_collecteur, e.has_collecteur? ? e.collecteur.nom : nil
        e.set :nom_destination, e.destination? ? e.destination.nom : nil
        e.set :nom_produit, e.has_produit? ? e.produit.nom : nil
      end
    end
  end

  def set_associations
    set_nom_producteur
    set_nom_produit
  end

  def set_nom_producteur
    set :nom_producteur, has_producteur? ? producteur.nom : nil
  end

  def set_nom_produit
    set :nom_produit, has_produit? ? produit.nom : nil
  end
  def set_nom_destinataire
    set :nom_destinataire, has_destinataire? ? destinataire.nom : nil
  end
  def set_nom_collecteur
    set :nom_collecteur, has_collecteur? ? collecteur.nom : nil
  end
  def set_nom_destination
    set :nom_destination, has_destination? ? destination.nom : nil
  end
end

