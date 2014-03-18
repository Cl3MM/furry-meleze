# encoding: utf-8

class CompaniesController < ApplicationController
  before_filter :authenticate_utilisateur!, :get_type
  # GET /companies
  # GET /companies.json
  def index
    @companies = @klass.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  def search
    if params.has_key?(:query)
      @companies = @klass.where(nom: /#{params[:query]}/i).paginate(page: params[:page], per_page: 20)
      #binding.pry
    end
    respond_to do |format|
      if @companies.any?
        format.html { render action: "index" }
        format.json { render json: @companies, status: :created }
      else
        format.html { redirect_to @klass, alert: "Aucun #{@klass.name.downcase} trouvé :(" }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = @klass.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = @klass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = @klass.find(params[:id])
  end

  # POST /companies
  # POST /companies.json
  def create
    if(params.has_key?(@klass.name.downcase.to_sym))
      @company = @klass.new(params[@klass.name.downcase.to_sym])
    else 
      redirect_to polymorphic_path(@klass)
    end
    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "#{@company.nom} a bien été crée." }
        format.json { render json: @company, status: :created, location: @company }
      else
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @company = @klass.find(params[:id])

    unless params.has_key?(@klass.name.downcase.to_sym)
      redirect_to polymorphic_path(@klass)
    end
    respond_to do |format|
      if @company.update_attributes(params[@klass.name.downcase.to_sym])
        format.html { redirect_to @company, notice: "#{@company.nom} a bien été mis à jour." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to @company.class }
      format.json { head :no_content }
    end
  end

  private
    def company_type
      if params.has_key?(:type) && ["destinataire"].include?(params[:type].downcase)
        params[:type].constantize
      else
        redirect_to root_url
      end
    end
    def get_type
      resource = request.path.split('/')[1] if request.path.split('/').size >= 1
      redirect_to root_url, alert: "Impossible de trouver la ressource demandée" unless ["destinataires", "collecteurs", "producteurs"].include?(resource.downcase)
      @klass   = resource.singularize.capitalize.constantize
    end
end
