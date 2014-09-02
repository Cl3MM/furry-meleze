# encoding: utf-8

class BonDeSortiesController < ApplicationController
  before_filter :authenticate_utilisateur!
  before_filter :set_bds, only: [:show]
  helper_method :sort_column, :sort_direction, :find_sorted_column

  def index
    #@ebsdds = Ebsdd.search(params).order_by([sort_column, sort_direction]).paginate(page: params[:page], per_page: 15)
    @bds = BonDeSortie.all.order_by([sort_column, sort_direction]).paginate(page: params[:page], per_page: 15)
  end
  def new
    @bds = BonDeSortie.new
    @errors = {}
    @dispo = Ebsdd.where(status: :attente_sortie).count
  end

  def prout
    bd = BonDeSortie.find(params[:id])
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
    binding.pry
    unless params[:transporteur].present? and params[:date_sortie].present?
      err = []
      err << "Veuillez saisir un transporteur" unless params[:transporteur].present?
      err << "Veuillez saisir une date de sortie" unless params[:date_sortie].present?
      flash[:error] = err.join(", ")
      @errors = {}
      render action: 'new' and return
    end
    if params[:ids].present? && params[:destinataire].present?
      @destination = Destination.find_by(nom: params[:destinataire])
      if @destination.nil?
        flash[:error] = "Impossible de trouver la destination"
        @errors = {}
        render action: 'new' and return
      end
      @bds = BonDeSortie.new(
        poids: params[:poidsHidden],
        cap: params[:cap],
        codedr_cadre12: params[:codedr],
        transporteur: params[:transporteur],
        date_sortie: Date.strptime(params[:date_sortie], "%d-%m-%Y"),
        codedr_cadre2: "R13")
      @bds.produit = Produit.find params[:type_dechet]
      @bds.destination = @destination
      @errors = {}
      params[:ids].each do |bid|
        e = Ebsdd.find_by(bid: bid)
        @errors[e.bid.to_sym] = e.errors.messages unless e.valid?
      end
      if @errors.any?
        render 'new' and return
      end
      binding.pry
      params[:ids].each do |bid|
        e = Ebsdd.find_by(bid: bid)
        e.set(:status, :clos)
        @bds.ebsdds << e
        #e.save!
      end
      @bds.set_type
      if @bds.save!
        redirect_to bon_de_sortie_path(@bds), notice: "Le Bon de Sortie a été créé avec succès !"
      else
        flash[:error] = "Impossible d'enregistrer le bon de sortie."
        render action: 'new'
      end
    else
      flash[:error] = "Impossible d'enregistrer le bon de sortie : la destination n'a pas été trouvé"
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

  def sort_column
    case params[:sort]
    when "Traitement"
      return :codedr_cadre12
    when "Destination"
      return :destination_id
    when "id"
      return :id
    when "Type de Déchet"
      return :produit_id
    when "Créé le"
      return :date_sortie
    when "Poids"
      return :poids
    else
      return :id
    end
    #Ebsdd.attribute_names.include?(params[:sort]) ? params[:sort] : "bid"
  end

  def find_sorted_column
    case sort_column
    when :codedr_cadre12
      return "Traitement"
    when :destination_id
      return "Destination"
    when :id
      return "id"
    when :produit_id
      return "Type de Déchet"
    when :date_sortie
      "Créé le"
    when :poids
      "Poids"
    else
      return :id
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  private

  def set_bds
    #binding.pry
    @bds = BonDeSortie.find(params[:id])
  end
end
