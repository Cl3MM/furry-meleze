# encoding: utf-8
class ProduitsController < ApplicationController
  before_filter :authenticate_utilisateur!
  before_filter :set_produit, only: [:show, :edit, :update, :destroy]

  # GET /produits
  # GET /produits.json
  def index
    @produits = Produit.all.order_by(nom: 1).paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @produits }
    end
  end

  def search
    if params.has_key?(:query)
      @produits = Produit.where(nom: /#{params[:query]}/i).order_by(nom: 1).paginate(page: params[:page], per_page: 50)
      #binding.pry
    end
    respond_to do |format|
      if @produits.any?
        format.html { render action: "index" }
        format.json { render json: @produits, status: :created }
      else
        format.html { redirect_to produits_path, alert: "Aucun produit trouvé :(" }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
  # GET /produits/1
  # GET /produits/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @produit }
    end
  end

  # GET /produits/new
  # GET /produits/new.json
  def new
    @produit = Produit.new
    @produit.references = []

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @produit }
    end
  end

  # GET /produits/1/edit
  def edit
  end

  # POST /produits
  # POST /produits.json
  def create
    params[:produit][:references] = if params[:produit][:references].present?
     if params[:produit][:references] =~ /,/
       params[:produit][:references].split(",")
     else
       [ params[:produit][:references] ]
     end
    else
      []
    end
    @produit = Produit.new(params[:produit])
    respond_to do |format|
      if @produit.save
        format.html { redirect_to @produit, notice: "#{@produit.nom} a bien été crée." }
        format.json { render json: @produit, status: :created, location: @produit }
      else
        @produit.references = [] if @produit.references.blank?
        format.html { render action: "new" }
        format.json { render json: @produit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /produits/1
  # PUT /produits/1.json
  def update
    params[:produit][:references] = if params[:produit][:references].present?
     if params[:produit][:references] =~ /,/
       params[:produit][:references].split(",")
     else
       [ params[:produit][:references] ]
     end
    else
      []
    end
    respond_to do |format|
      if @produit.update_attributes(params[:produit])
        format.html { redirect_to @produit, notice: "#{@produit.nom} a bien été mis à jour." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @produit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /produits/1
  # DELETE /produits/1.json
  def destroy
    @produit.destroy

    respond_to do |format|
      format.html { redirect_to produits_path }
      format.json { head :no_content }
    end
  end

  private

  def set_produit
    #binding.pry
    @produit = Produit.find(params[:id])
  end
end
