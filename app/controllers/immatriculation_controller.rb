# encoding: utf-8

class ImmatriculationController < ApplicationController
  def create
    @immatriculation = nil
    if params[:id].present?
      valeur = params[:id].strip.upcase.gsub(/\s|\W/, '').html_safe
      unless valeur.blank? || Immatriculation.where(valeur: valeur).exists?
        @immatriculation = Immatriculation.create(valeur: valeur)
      end
    end
    respond_to do | format |
      unless @immatriculation.nil?
        format.html { render action: 'new' }
        format.json { render json: {id: @immatriculation.id, valeur: @immatriculation.valeur}.to_json }
      else
        format.html { render text: "erreur" }
        format.json { render json: {} }
      end
    end
  end
end
