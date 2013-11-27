# encoding: utf-8

class EbsddsController < ApplicationController
  before_filter :set_ebsdd, only: [:download, :template, :show, :edit, :update, :destroy]
  before_filter :check_incomplete, only: [:import, :upload]

  # GET /ebsdds/import
  def import
  end

  def reset
    Ebsdd.delete_all
    Attachment.delete_all
    redirect_to root_path, notice: "Base de données réinitialisée avec succès !"
  end
  def template
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.to_ebsdd_template, filename: "#{@ebsdd.id}_template.csv" }
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def download
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.to_ebsdd, filename: "#{@ebsdd.id}.csv" }
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def upload
    if params.has_key? :file
      file = params[:file]
      if ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"].include? file.content_type
        validation = Ebsdd.import(params[:file])
        if validation[:errors].any?
          redirect_to ebsdds_import_path, alert: validation[:errors].join("<br/>")
        end
        @content = validation[:rows]
        flash.notice = "Fichier importé avec succès. Veuillez maintenant compléter les eBSDD nouvellement créés."
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
    @ebsdds = Ebsdd.all
  end

  # GET /ebsdds/1
  # GET /ebsdds/1.json
  def show
  end

  # GET /ebsdds/new
  def new
    @ebsdd = Ebsdd.new
  end

  # GET /ebsdds/1/edit
  def edit
  end

  # POST /ebsdds
  # POST /ebsdds.json
  def create
    @ebsdd = Ebsdd.new(ebsdd_params)

    respond_to do |format|
      if @ebsdd.save
        format.html { redirect_to @ebsdd, notice: 'Ebsdd was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ebsdd }
      else
        format.html { render action: 'new' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ebsdds/1
  # PATCH/PUT /ebsdds/1.json
  def update
    respond_to do |format|
      if @ebsdd.update(ebsdd_params)
        format.html { redirect_to @ebsdd, notice: 'Ebsdd was successfully updated.' }
        format.json { head :no_content }
      else
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
    def ebsdd_params
      params.require(:ebsdd).permit(:producteur)
    end

    def check_incomplete
      if Ebsdd.has_every_bsd_completed?
        redirect_to root_path, alert: "Certains eBSDDs sont encore incomplets. Veuillez d'abord les compléter afin de procéder à un nouvel import."
      end
    end
end
