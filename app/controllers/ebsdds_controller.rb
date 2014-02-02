# encoding: utf-8

class EbsddsController < ApplicationController
  before_filter :authenticate_utilisateur!
  before_filter :set_ebsdd, only: [:annexe_export, :download, :template, :show, :edit, :update, :destroy]
  before_filter :check_incomplete, only: [:import, :upload]

  # GET /ebsdds/import
  def import
  end

  def reset
    Ebsdd.delete_all
    Attachment.delete_all
    redirect_to root_path, notice: "Base de données réinitialisée avec succès !"
  end

  def annexe_export
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.annexe_2_to_csv, filename: "#{@ebsdd.id}_annexe_2.csv" }
    end
  end
  def selection
    @min = (params.has_key?(:date_min) ? Date.strptime(params[:date_min], "%d-%m-%Y") : Time.now.beginning_of_month)
    @max = (params.has_key?(:date_max) ? Date.strptime(params[:date_max], "%d-%m-%Y") : Time.now.end_of_month)
    @ebsdds = Ebsdd.multiebsdd_search(@min, @max).asc(:bordereau_id) #.paginate(page: params[:page], per_page: 15)
    #else
      #@ebsdds = Ebsdd.between(bordereau_date_creation: @min..@max)#.order_by(:bordereau_date_creation)#.paginate(page: params[:page], per_page: 15)
    #end
  end
  def export
    send_data Ebsdd.to_multi(params), filename: "Export_EcoDDS_multi_ebsdds_du_#{Time.now.strftime("%d-%m-%Y")}.csv"
  end
  def download
    @ebsdd.inc_export
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.to_ebsdd, filename: "#{@ebsdd.id}.csv" }
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def upload
    if params.has_key? :file
      file = params[:file]
      if ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          "application/vnd.ms-excel"
      ].include? file.content_type
        errors = Ebsdd.import2(params[:file])
        if errors.any?
          redirect_to ebsdds_import_path, alert: errors.join("<br/>")
        else
          redirect_to root_path, notice: "Fichier importé avec succès. Veuillez maintenant compléter les eBSDD nouvellement créés."
        end
      else
        redirect_to ebsdds_import_path, alert: "Le fichier du format est incorrect. Merci d'importer seulement des fichiers Excel ou CSV"
      end
    else
      redirect_to ebsdds_import_path, alert: "Merci de choisir un fichier pour passer à l'étape suivante."
    end
  end
  # GET /ebsdds
  # GET /ebsdds.json
  def index
    @ebsdds = Ebsdd.search(params).paginate(page: params[:page], per_page: 15)
    @status = (params.has_key?(:status) ? params[:status].to_sym : :empty)
  end

  # GET /ebsdds/1
  # GET /ebsdds/1.json
  def show
  end

  # GET /ebsdds/new
  def new
    @productable = Producteur.where(is_collecteur: false).build
    @ebsdd = Ebsdd.new
    @ebsdd.productable = @productable
    #@collectable = Producteur.where(is_collecteur: true).build
  end

  # GET /ebsdds/1/edit
  def edit
    @productable = @ebsdd.productable || Producteur.where(is_collecteur: false).build
    @destination = @ebsdd.destination || Destination.find_by(nomenclatures: @ebsdd.dechet_denomination) || Destination.new
  end

  # POST /ebsdds
  # POST /ebsdds.json
  def create
    @ebsdd = Ebsdd.new(params[:ebsdd])

    respond_to do |format|
      saved = @ebsdd.save
      valid = @ebsdd.productable.valid?
      if saved && valid
        format.html { redirect_to @ebsdd, notice: 'L\'EBSDD a été crée avec succès ! ' }
        format.json { render action: 'show', status: :created, location: @ebsdd }
      elsif !saved && valid
        format.html { render action: 'edit' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      else
        @productable = Producteur.where(is_collecteur: false).build
        format.html { render action: 'new' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_form
    respond_to do |format|
        format.html { render :search_form, layout: false }
        #format.json { head :no_content }
    end
  end

  # PATCH/PUT /ebsdds/1
  # PATCH/PUT /ebsdds/1.json
  def update
    @ebsdd = Ebsdd.find(params[:id])
    respond_to do |format|
      valid = @ebsdd.productable.valid?
      if @ebsdd.update_attributes(params[:ebsdd]) && valid
        format.html { redirect_to @ebsdd, notice: 'Le eBSDD à été modifié avec succès.' }
        format.json { head :no_content }
      else
        @productable = @ebsdd.productable || Producteur.where(is_collecteur: false).build
        @destination = @ebsdd.destination || Destination.find_by(nomenclatures: @ebsdd.dechet_denomination) || Destination.new
        format.html { render action: 'edit' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ebsdds/1
  # DELETE /ebsdds/1.json
  def destroy
    @ebsdd.destroy
    respond_to do |format|
      format.html { redirect_to ebsdds_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ebsdd
    #binding.pry
    @ebsdd = Ebsdd.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  #def ebsdd_params
  #params.require(:ebsdd).permit(:num_cap, :dechet_consistance, :dechet_denomination, :dechet_nomenclature, :id)
  #end

  def check_incomplete
    if Ebsdd.has_every_bsd_completed?
      redirect_to root_path, alert: "Certains eBSDDs sont encore incomplets. Veuillez d'abord les compléter afin de procéder à un nouvel import."
    end
  end
end
