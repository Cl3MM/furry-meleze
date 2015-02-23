# encoding: utf-8

class EbsddsController < ApplicationController
  before_filter :authenticate_utilisateur!
  before_filter :set_ebsdd, only: [:print_pdf, :annexe_export, :download, :template, :show, :edit, :update, :destroy]
  before_filter :check_incomplete, only: [:import, :upload]
  helper_method :sort_column, :sort_direction, :find_sorted_column

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
      format.csv { send_data @ebsdd.annexe_2_to_csv.encode("iso-8859-1"), type: 'text/csv; charset=iso-8859-1;', filename: "#{@ebsdd.id}_annexe_2.csv" }
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
    send_data Ebsdd.to_multi(params).encode("iso-8859-1"), type: 'text/csv; charset=iso-8859-1;', filename: "Export_EcoDDS_multi_ebsdds_du_#{Time.now.strftime("%d-%m-%Y")}.csv"
  end
  def mark_as_deleted
    return render json: { error: errors  }, status: 500 unless params[:bids].present?
    ids = []
    Ebsdd.in(bid: params[:bids]).each do | b |
      unless b.pesees.any? || b.poids > 0
        #b.update_attribute(:status, :deleted)
        #b.update_attribute(:deleted_at, Time.now)
        #ids << b.bid
        ids << b.bid
        b.destroy
      end
    end

    render json: ids
  end
  def change_ebsdd_en_attente_statut
    if params[:id].present?
      ebsdd = Ebsdd.find_by(bid: params[:id])
      if ebsdd
        ebsdd.set(:status, :attente_sortie)
        ebsdd.set(:attente_sortie_created_at, Time.now)
        respond_to do | format |
          format.json { render json: { id: params[:id] } }
        end
      else
        respond_to do | format |
          format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do | format |
        format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
      end
    end
  end
  def change_ebsdd_nouveau_statut
    if params[:id].present?
      ebsdd = Ebsdd.find_by(bid: params[:id])
      if ebsdd
        ebsdd.set(:status, :en_attente)
        ebsdd.set(:en_attente_created_at, Time.now)
        respond_to do | format |
          format.json { render json: { id: params[:id] } }
        end
      else
        respond_to do | format |
          format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do | format |
        format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
      end
    end
  end
  def change_nouveau_statut
    if params[:ids].present?
      ids = params[:ids]
      ids.each_with_index do | id, ix |
        ebsdd = Ebsdd.find_by(bid: id)
        ebsdd.set(:status, :en_attente)
      end
      msg = { data: ids }
      respond_to do | format |
        format.json { render json: msg }
      end
    else
      #format.html { render action: 'new' }
      respond_to do | format |
        format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
      end
    end
  end
  def change_en_attente_statut
    if params[:ids].present?
      ids = params[:ids]
      outIds, err = [], []
      ids.each_with_index do | id, ix |
        ebsdd = Ebsdd.find_by(bid: id)
        unless ebsdd.bordereau_poids.blank?
          ebsdd.set(:status, :attente_sortie)
          outIds << ebsdd.bid
        else
          err << ebsdd.bid
        end
      end
      msg = { data: outIds, err: err }
      respond_to do | format |
        format.json { render json: msg }
      end
    else
      #format.html { render action: 'new' }
      respond_to do | format |
        format.json { render json: { error: "aucun bsd à traiter" }, status: :unprocessable_entity }
      end
    end
  end
  def nouveaux_pdfs
    if params[:ids].present?
      ids, pdf_list = params[:ids], []
      path = File.join(Rails.root, "tmp", "pdfs")
      FileUtils.remove_dir(path) if File.exists? path
      FileUtils.mkdir_p path
      ids.each_with_index do | id, ix |
        ebsdd = Ebsdd.find_by(bid: id)
        pdf_path = File.join( path, ebsdd.bid ) + ".pdf"
        pdf = EbsddPdf.new(ebsdd, :nouveau)
        pdf.render_file pdf_path
        pdf_list << pdf_path
      end
      cmd = "pdftk #{pdf_list.join(" ")} cat output #{File.join(path, "Collecte_du_#{Date.today.strftime("%d-%m-%y")}.pdf")}"
      %x(#{cmd})
      send_file File.join(path, "Collecte_du_#{Date.today.strftime("%d-%m-%y")}.pdf"), type: "application/pdf"
    else
      #format.html { render action: 'new' }
      respond_to do | format |
        format.json { render json: { error: "aucun bsd à traiter"}, status: :unprocessable_entity }
      end
    end
  end
  def print_pdf
    status = params[:status].present? ? params[:status].to_sym : :empty
    respond_to do |format|
      format.pdf do
        pdf = EbsddPdf.new(@ebsdd, status)
        send_data pdf.render, filename: "#{@ebsdd.bordereau_id}_#{Date.today.strftime("%d-%m-%y")}.pdf",
          type: "application/pdf"# , disposition: "inline"
      end
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def export_pesee_pdf
    @ebsdd = Ebsdd.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = PeseePdf.new(@ebsdd)
        send_data pdf.render, filename: "#{@ebsdd.bordereau_id}_ticket_de_pesee_#{Date.today.strftime("%d-%m-%y")}.pdf",
          type: "application/pdf"# , disposition: "inline"
      end
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def download
    @ebsdd.inc_export
    respond_to do |format|
      format.html
      format.csv { send_data @ebsdd.to_ebsdd.encode("iso-8859-1"), type: 'text/csv; charset=iso-8859-1;', filename: "#{@ebsdd.id}.csv" }
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
    @ebsdds = Ebsdd.search(params)
    if sort_column == :poids
      Pry.config.input = STDIN
      Pry.config.output = STDOUT
      @ebsdds = @ebsdds.to_a.sort_by(&:poids)
      @ebsdds = @ebsdds.reverse if sort_direction == "desc"
      @ebsdds = @ebsdds.paginate(page: params[:page], per_page: 25)
    else
      @ebsdds = @ebsdds.order_by([sort_column, sort_direction]).paginate(page: params[:page], per_page: 25)
    end

    @status = (params.has_key?(:status) ? params[:status].to_sym : :tous)
    @status = :clos if @status == :closs
    @status = :nouveau if @status == :tous && !current_utilisateur.is_admin?
  end

  # GET /ebsdds/1
  # GET /ebsdds/1.json
  def show
  end

  # GET /ebsdds/new
  def new
    @ebsdd = Ebsdd.new
    #@collecteur = Producteur.where(is_collecteur: true).build
  end

  # GET /ebsdds/1/edit
  def edit
    @destination = @ebsdd.destination || Destination.find_by(nomenclatures: @ebsdd.dechet_denomination) || Destination.new
  end

  def types_dechet_a_sortir
    #pids = Ebsdd.where(status: :attente_sortie).distinct(:produit_id)
    aggregate = Ebsdd.collection.aggregate( [ { "$match" => { "status" => "attente_sortie" } }, { "$group" => { "_id" => "$produit_id", count: {"$sum" =>  1} } } ])
    types = unless aggregate.nil?
      results = aggregate.reduce({}) { |h, ar| h[ar["_id"]] = ar["count"] ; h }
      Produit.asc(:nom).find(results.keys).map do | p |
        {
          text: "#{p.nom} - #{results[p.id]} en stock",
          id: p.id
        }
      end
    else
      nil
    end
    #types = pids.nil? ? nil : Produit.find(pids).map{ |p| {text: p.nom, id: p.id} }
    render json: types
  end

  def a_sortir
    if params[:produit_id].present?
      is_ecodds = params.has_key?(:is_ecodds) && params[:is_ecodds] == "true" ? true : false
      produit_id = params[:produit_id]
      produit = Produit.find(produit_id)
      @ebsdds = Ebsdd.where(status: :attente_sortie).and(produit_id: produit_id).and(is_ecodds: is_ecodds)
      @destinataire = produit.try(:references).try(:first)
      @codedr = produit.try(:code_dr_expedition)
      respond_to do | format |
        format.js
      end
    else
      render json: { error: "Aucune denomination"}, status: :unprocessable_entity
    end
  end

  def statut_precedent
    unless params[:id].present?
      redirect_to root_path, alert: "Veuillez spécifier un numéro eBsdd"
      return redirect_to root_path
    end
    @ebsdd = Ebsdd.find( params[:id] )
    @ebsdd.prev_status
    redirect_to :back
  end
  def statut_suivant
    return redirect_to :back, alert: "Veuillez spécifier un numéro eBsdd" unless params[:id].present?
    @ebsdd = Ebsdd.find( params[:id] )
    err = []
    err << "Impossible de trouver l'eBsdd ##{params[:id]}" unless params[:id].present?
    err << "Impossible de changer de statut : le poids ne peut être vide" if @ebsdd.status == :en_attente && @ebsdd.pesees.empty?
    err << "Impossible de changer de statut : le type de conditionnement ne peut être vide" if @ebsdd.status == :en_attente && @ebsdd.dechet_conditionnement.nil?
    return redirect_to :back, alert: err.join(" ") if err.any?
    @ebsdd.next_status
    redirect_to :back
  end
  # POST /ebsdds
  # POST /ebsdds.json
  def create
    params[:ebsdd][:producteur_id] = nil if params[:ebsdd].has_key?(:producteur_id) && params[:ebsdd][:producteur_id].blank?
    params[:ebsdd][:destinataire_id] = nil if params[:ebsdd].has_key?(:destinataire_id) && params[:ebsdd][:destinataire_id].blank?
    params[:ebsdd][:dechet_conditionnement] = nil if params[:ebsdd].has_key?(:dechet_conditionnement) && params[:ebsdd][:dechet_conditionnement].blank?

    @ebsdd = Ebsdd.new(params[:ebsdd])
    #@ebsdd.bordereau_date_reception = @ebsdd.bordereau_date_transport
    respond_to do |format|
      if @ebsdd.save
        format.html { redirect_to @ebsdd, notice: "L'EBSDD a été crée avec succès !" }
        format.json { render action: 'show', status: :created, location: @ebsdd }
      else
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

  def pesee
    @ebsdd = Ebsdd.find(params[:id])
    @tares = Tare.all
  end

  def delete_pesee
    if current_utilisateur.is_admin?
      @ebsdd = Ebsdd.find(params[:id])
      deleted = @ebsdd.pesees.delete_all(dsd: params[:pid])
      render json: { deleted: deleted, id: params[:pid] }
    else
      render json: {error: "Seuls les administrateurs sont habilités à supprimer des pesées déjà enregistrées", id: params[:pid]}, status: :unprocessable_entity
    end
  end
  # PATCH/PUT /ebsdds/1
  # PATCH/PUT /ebsdds/1.json
  def update
    # Si l'opérateur tape une virgule à la place d'un point dans le poids
    params[:ebsdd][:poids].gsub!(",", ".") if params[:ebsdd][:poids].present? && params[:ebsdd][:poids] =~ /,/
    params[:ebsdd][:dechet_conditionnement] = nil if params[:ebsdd].has_key?(:dechet_conditionnement) && params[:ebsdd][:dechet_conditionnement].blank?
    if params[:ebsdd][:poids].present?
      unless params[:ebsdd][:poids].to_f <= 0
        params[:ebsdd][:bordereau_poids] =  params[:ebsdd][:poids]
      end
    end
    @ebsdd = Ebsdd.find(params[:id])
    respond_to do |format|
      if @ebsdd.update_attributes(params[:ebsdd])
        format.html { redirect_to @ebsdd, notice: 'Le eBSDD à été modifié avec succès.' }
        format.json { head :no_content }
      else
        #@producteur = @ebsdd.producteur || Producteur.where(is_collecteur: false).build
        #@destination = @ebsdd.destination || Destination.find_by(nomenclatures: @ebsdd.dechet_denomination) || Destination.new
        format.html { render action: 'edit' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      end
    end
  end

  def clone
    old_ebsdd = Ebsdd.find(params[:id])
    respond_to do |format|
      #old_ebsdd.bordereau_poids = 0
      @ebsdd = old_ebsdd.dup
      @ebsdd.status = :nouveau
      flash[:notice] = "eBsdds cloné avec succès !"
      format.html { render action: 'new', notice: "eBsdds cloné avec succès !" }
    end
  end

  def split
    params[:ebsdd][:bordereau_poids].gsub!(",", ".") if params[:ebsdd][:bordereau_poids].present? && params[:ebsdd][:bordereau_poids] =~ /,/
    @ebsdd = Ebsdd.find(params[:id])
    respond_to do |format|
      if @ebsdd.update_attributes(params[:ebsdd])
        @ebsdd = Ebsdd.new(params[:ebsdd])
        @ebsdd.bordereau_poids = 0
        @ebsdd.ecodds_id = nil
        flash[:notice] = "eBsdds enregistré avec succès ! Veuillez remplir le nouveau poids."
        format.html { render action: 'new', notice: "eBsdds enregistré avec succès ! Veuillez remplir le nouveau poids." }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ebsdd.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ebsdds/1
  # DELETE /ebsdds/1.json
  def destroy
    if @ebsdd.pesees.any? || @ebsdd.poids > 0
      @ebsdd.update_attribute(:status, :deleted)
      @ebsdd.update_attribute(:deleted_at, Time.now)
    else
      @ebsdd.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back }
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

  def sort_column
    case params[:sort]
    when "# ecodds"
      return :ecodds_id
    when "# ebsdd"
      return :bid
    when "Producteur"
      return :nom_producteur
    when "Type déchet"
      return :nom_produit
    when "Date création"
      return :bordereau_date_creation
    when "Poids"
      return :poids
    else
      return :bid
    end
    #Ebsdd.attribute_names.include?(params[:sort]) ? params[:sort] : "bid"
  end

  def find_sorted_column
    case sort_column
    when :ecodds_id
      return "# ecodds"
    when :bid
      return "# ebsdd"
    when :nom_producteur
      return "Producteur"
    when :nom_produit
      return "Type déchet"
    when :bordereau_date_creation
      "Date création"
    when :poids
      "Poids"
    else
      return :bid
    end
  end
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
