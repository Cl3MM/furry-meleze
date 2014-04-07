# encoding: utf-8

class BonDeSortiesController < ApplicationController
  before_filter :authenticate_utilisateur!
  before_filter :set_bds, only: [:show]

  def index
    @bds = BonDeSortie.all.paginate(page: params[:page], per_page: 15)
  end
  def new
    @bds = BonDeSortie.new
  end

  def create
    if params[:ids].present? && params[:destinataire].present?
      @bds = BonDeSortie.new()
      @destination = Destination.find_by(nom: params[:destinataire])
      @bds.destination = @destination
      params[:ids].each do |bid|
        e = Ebsdd.find_by(bid: bid)
        e.set(:status, :clos)
        @bds.ebsdds << e
        e.save!
      end
      if @bds.save!
        redirect_to bon_de_sortie_path(@bds), notice: "L'EBSDD a été crée avec succès !"
      else
        render action: 'new', error: "Impossible d'enregistrer le bon de sortie."
      end
    else
      render action: 'new', error: "Impossible d'enregistrer le bon de sortie."
      #render json: { error: "Aucun eBSDD a traiter, ou destinataire manquant"}, status: :unprocessable_entity
    end
  end
  def show
  end

  private

  def set_bds
    #binding.pry
    @bds = BonDeSortie.find(params[:id])
  end
end
