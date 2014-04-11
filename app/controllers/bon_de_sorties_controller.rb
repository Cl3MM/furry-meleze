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

  def prout
    bd = BonDeSortie.find_by(id: params[:id])
    respond_to do |format|
      format.pdf do
        pdf = EbsddPdf.new nil, :bon_de_sortie, bd
        send_data pdf.render, filename: "#{bd.id}_#{Date.today.strftime("%d-%m-%y")}.pdf",
          type: "application/pdf"# , disposition: "inline"
      end
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end
  def create
    if params[:ids].present? && params[:destinataire].present?
      @destination = Destination.find_by(nom: params[:destinataire])
      if @destination.nil?
        flash[:error] = "Impossible de trouver la destination"
        render action: 'new' and return
      end
      @bds = BonDeSortie.new(
        poids: params[:poidsHidden],
        codedr_cadre12: params[:codedr],
        codedr_cadre2: "R13",
        denomination_id: params[:type_dechet] )
      @bds.destination = @destination
      params[:ids].each do |bid|
        e = Ebsdd.find_by(bid: bid)
        e.set(:status, :clos)
        @bds.ebsdds << e
        #e.save!
      end
      if @bds.save!
        redirect_to bon_de_sortie_path(@bds), notice: "L'EBSDD a été créé avec succès !"
      else
        flash[:error] = "Impossible d'enregistrer le bon de sortie."
        render action: 'new'
      end
    else
      flash[:error] = "Impossible d'enregistrer le bon de sortie."
      render action: 'new'
      #render json: { error: "Aucun eBSDD a traiter, ou destinataire manquant"}, status: :unprocessable_entity
    end
  end
  def show
  end
  def search
    if params.has_key?(:query)
      @bds = BonDeSortie.where(id: /#{params[:query]}/i).paginate(page: params[:page], per_page: 20)
      #binding.pry
    end
    respond_to do |format|
      if @bds
        format.html { render action: "index" }
        format.json { render json: @bds, status: :created }
      else
        format.html { redirect_to :producteurs_path, notice: 'Aucun producteur trouvé :(' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end


  private

  def set_bds
    #binding.pry
    @bds = BonDeSortie.find(params[:id])
  end
end
