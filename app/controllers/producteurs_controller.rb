# encoding: utf-8
class ProducteursController < CompaniesController
  def upload
    if params.has_key? :file
      file = params[:file]
      if ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          "application/vnd.ms-excel"
      ].include? file.content_type
        if( Producteur.import(params[:file]) )
          redirect_to producteurs_path, notice: "Fichier importé avec succès."
        else
          redirect_to producteurs_path, alert: "Un problème est survenu durant l'importation."
        end
      else
        redirect_to producteurs_import_path, alert: "Le fichier du format est incorrect. Merci d'importer seulement des fichiers Excel ou CSV"
      end
    else
      redirect_to producteurs_import_path, alert: "Merci de choisir un fichier pour passer à l'étape suivante."
    end
  end
  # GET /producteurs/import
  def import
  end

  def download
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.to_ebsdd, filename: "#{@ebsdd.id}.csv" }
    end
  end

  # GET /producteurs
  # GET /producteurs.json
  def index
    @producteurs = Producteur.search(params).paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @producteurs }
    end
  end

  # GET /producteurs/1
  # GET /producteurs/1.json
  def show
    @producteur = Producteur.find(params[:id])
    @ebsdds = @producteur.ebsdds.where(created_at: Date.today-50..Date.today.end_of_month).order_by(updated_at: 1)
    #@ebsdds = @producteur.ebsdds.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order_by(updated_at: 1)
    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.json { render json: @producteur }
    end
  end

  def monthly_stat_by_type
    @producteur = Producteur.find(params[:id])
    #Date.today.beginning_of_month..Date.today.end_of_month
  end
  ## GET /producteurs/new
  ## GET /producteurs/new.json
  #def new
    #@producteur = Producteur.new
    #respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @producteur }
    #end
  #end

  ## GET /producteurs/1/edit
  #def edit
    #@producteur = Producteur.find(params[:id])
  #end

  ## POST /producteurs
  ## POST /producteurs.json
  #def create
    #@producteur = Producteur.new(params[:producteur])

    #respond_to do |format|
      #if @producteur.save
        #format.html { redirect_to @producteur, notice: 'Le producteur a été crée avec succès !' }
        #format.json { render json: @producteur, status: :created, location: @producteur }
      #else
        #format.html { render action: "new" }
        #format.json { render json: @producteur.errors, status: :unprocessable_entity }
      #end
    #end
  #end

  def search
    if params.has_key?(:query)
      @producteurs = Producteur.where(nom: /#{params[:query]}/i).paginate(page: params[:page], per_page: 20)
      #binding.pry
    end
    respond_to do |format|
      if @producteurs
        format.html { render action: "index" }
        format.json { render json: @producteurs, status: :created }
      else
        format.html { redirect_to :producteurs_path, notice: 'Aucun producteur trouvé :(' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  ## PUT /producteurs/1
  ## PUT /producteurs/1.json
  #def update
    #@producteur = Producteur.find(params[:id])

    #respond_to do |format|
      #if @producteur.update_attributes(params[:producteur])
        #format.html { redirect_to @producteur, notice: 'Le producteur a été modifié avec succès !' }
        #format.json { head :no_content }
      #else
        #format.html { render action: "edit" }
        #format.json { render json: @producteur.errors, status: :unprocessable_entity }
      #end
    #end
  #end

  ## DELETE /producteurs/1
  ## DELETE /producteurs/1.json
  #def destroy
    #@producteur = Producteur.find(params[:id])
    #@producteur.destroy

    #respond_to do |format|
      #format.html { redirect_to producteurs_url }
      #format.json { head :no_content }
    #end
  #end
end
