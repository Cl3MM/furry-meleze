class DestinatairesController < ApplicationController
  # GET /destinataires
  # GET /destinataires.json
  def index
    @destinataires = Destinataire.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @destinataires }
    end
  end

  # GET /destinataires/1
  # GET /destinataires/1.json
  def show
    @destinataire = Destinataire.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @destinataire }
    end
  end

  # GET /destinataires/new
  # GET /destinataires/new.json
  def new
    @destinataire = Destinataire.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @destinataire }
    end
  end

  # GET /destinataires/1/edit
  def edit
    @destinataire = Destinataire.find(params[:id])
  end

  # POST /destinataires
  # POST /destinataires.json
  def create
    @destinataire = Destinataire.new(params[:destinataire])

    respond_to do |format|
      if @destinataire.save
        format.html { redirect_to @destinataire, notice: 'Destinataire was successfully created.' }
        format.json { render json: @destinataire, status: :created, location: @destinataire }
      else
        format.html { render action: "new" }
        format.json { render json: @destinataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /destinataires/1
  # PUT /destinataires/1.json
  def update
    @destinataire = Destinataire.find(params[:id])

    respond_to do |format|
      if @destinataire.update_attributes(params[:destinataire])
        format.html { redirect_to @destinataire, notice: 'Destinataire was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @destinataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /destinataires/1
  # DELETE /destinataires/1.json
  def destroy
    @destinataire = Destinataire.find(params[:id])
    @destinataire.destroy

    respond_to do |format|
      format.html { redirect_to destinataires_url }
      format.json { head :no_content }
    end
  end
end
