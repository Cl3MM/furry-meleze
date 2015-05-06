# encoding: utf-8

#TODO
#Documents à recevoir :
#Séverine : liste produits et liste contenants pour bsd non ecodds

#Edition BSD
#- Ajouter bouton "enregistrer" à côté du dernier cadre en cours de modification
#- ou Ajouter bouton (fenêtre qui se lève) en bas pour remonter en haut
#- Fonction "export ecodds" s'affiche QUE pour les bsd ecodds
#- Afficher le nombre d'exports du bsd
#- Afficher produits différents et contenants différents pour bsd non ecodds

#Cadre 12 : Ajouter une liste pour "non ecodds"

#Récipissé + limite de validité du collecteur à stocker dans le bsd

#- Lors d'une sortie d'un déchet, on remplit l'annexe 2.

#TODO :
  #Recherche :
    #Critères :
      #Type de déchet (pateux, inflamable)
      #Date de réception (date du cadre 8 bordereau_date_transport)
      #Producteur du déchet
      #Destination du déchet
      #Numéro bordereau_id ou ecodds_id
      #Intervalle de temps (du 26 Juillet au 31 Septembre)

class Ebsdd
  include Mongoid::Document
  include Mongoid::Timestamps

  include Pesable
  include Mongoable

  default_scope exists(archived: false).where(:status.ne => :deleted)

  def self.per_page
    15
  end

  before_create :normalize, :complete_new, :set_infos_from_collecteur, :set_is_ecodds
  before_update :set_status, :set_num_cap, :set_infos_from_collecteur, :set_is_ecodds

  def self.skip_before_update_callback
    Ebsdd.skip_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)
  end
  def self.set_before_update_callback
    Ebsdd.set_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)
  end
  def set_status
    if self[:status] == :import
      self[:status] = :incomplet
    elsif self[:status] == :incomplet
      self[:status] = :complet
    end
    true
  end
  def set_bordereau_id
    self[:bordereau_id] = "#{id}" # "#{Date.today.strftime("%Y%m%d")}#{"%04d" % (Ebsdd.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count + 1) }" if self[:status] == :nouveau
  end
  def set_infos_from_collecteur
    self[:recepisse] = collecteur.recepisse
    self[:limite_validite] = collecteur.limite_validite
    self[:mode_transport] = collecteur.mode_transport
    true
  end
  def set_is_ecodds
    val = (producteur.nom =~ /eco dds/i) == nil ? false : true
    set(:is_ecodds, val)
    set(:ecodds_id_str, "#{self[:ecodds_id]}") unless self[:ecodds_id].blank?
    true
  end
  def set_num_cap
    self[:num_cap] = num_cap_auto if num_cap.blank?
    true
  end

  #belongs_to :emitted, polymorphic: true, class_name: "Producteur", inverse_of: :emitted
  #belongs_to :collected, polymorphic: true, class_name: "Producteur", inverse_of: :collected
  belongs_to :producteur, inverse_of: :ebsdds
  belongs_to :destinataire, inverse_of: :ebsdds
  #belongs_to :prout
  belongs_to :collecteur, inverse_of: :ebsdds
  belongs_to :bon_de_sortie, inverse_of: :ebsdds
  belongs_to :produit, inverse_of: :ebsdds

  belongs_to :destination, inverse_of: :destination
  belongs_to :attachment
  #accepts_nested_attributes_for :producteur
  #accepts_nested_attributes_for :collecteur
  accepts_nested_attributes_for :destination
  attr_accessible :id, :_id

  field :_id, type: String, default: -> do
    counter = 1
    now = Time.now.strftime("%Y%m%d")
    start = Date.today.beginning_of_day
    fin = Date.today.end_of_day
    tmp = ""
    loop do
      tmp = "#{now}#{"%04d" % (Ebsdd.unscoped.between(created_at: start..fin).count + counter)}"
      #tmp = "201505060041" if tmp == "201505060040"
      counter += 1
      break unless Ebsdd.unscoped.find(bid: /#{tmp}/)#.exists?
    end
    Rails.logger.debug "tmp: #{tmp}"
    tmp
  end

  field :ecodds_id, type: Integer#, default: ->{ default_ecodds_id }
  field :ecodds_id_str, type: String#, default: ->{ default_ecodds_id }
  field :status, type: Symbol, default: :nouveau
  field :line_number, type: Integer
  field :bordereau_id, type: Integer
  field :bordereau_poids, type: Float
  field :bordereau_poids_ult, type: Float
  field :deleted_at, type: DateTime

  field :attente_sortie_created_at, type: DateTime
  field :en_attente_created_at, type: DateTime

  field :is_ecodds, type: Boolean, default: false

  field :ligne_flux_siret, type: String
  field :ligne_flux_nom, type: String
  field :ligne_flux_adresse, type: String
  field :ligne_flux_cp, type: String
  field :ligne_flux_ville, type: String
  field :ligne_flux_tel, type: String
  field :ligne_flux_fax, type: String
  field :ligne_flux_email, type: String, default: nil
  field :ligne_flux_responsable, type: String
  field :ligne_flux_poids, type: String
  field :ligne_flux_date_remise, type: Date
  field :ligne_flux_conditionnement_ult, type: Integer
  field :ligne_flux_nombre_colis_ult, type: String

  field :emetteur_siret, type: String
  field :emetteur_sortie_nom, type: String
  field :emetteur_adresse, type: String
  field :emetteur_cp, type: String
  field :emetteur_ville, type: String
  field :emetteur_tel, type: String
  field :emetteur_fax, type: String
  field :emetteur_email, type: String, default: nil
  field :emetteur_responsable, type: String

  field :destinataire_siret, type: String
  field :destinataire_nom, type: String
  field :destinataire_adresse, type: String
  field :destinataire_cp, type: String
  field :destinataire_ville, type: String
  field :destinataire_tel, type: String
  field :destinataire_fax, type: String
  field :destinataire_email, type: String, default: nil
  field :destinataire_responsable, type: String

  field :nomenclature_dechet_code_nomen_c, type: Integer
  field :nomenclature_dechet_code_nomen_a, type: Integer
  field :bordereau_date_transport, type: Date
  #field :bordereau_poids, type: Integer
  field :libelle, type: String
  field :bordereau_date_creation, type: Date
  field :num_cap, type: String
  field :dechet_denomination, type: Integer
  field :dechet_consistance, type: Integer
  field :dechet_nomenclature, type: String
  field :dechet_conditionnement, type: String
  field :dechet_nombre_colis, type: Integer
  field :type_quantite, type: String
  field :emetteur_nom, type: String
  field :code_operation, type: String
  field :traitement_prevu, type: String

  field :entreposage_siret,type: String
  field :entreposage_nom,type: String
  field :entreposage_adresse, type: String
  field :entreposage_cp, type: String
  field :entreposage_ville, type: String
  field :entreposage_tel, type: String
  field :entreposage_fax, type: String
  field :entreposage_email, type: String
  field :entreposage_responsable, type: String
  field :entreposage_poids, type: String
  field :entreposage_type_quantite, type: String
  field :entreposage_date, type: Date
  field :entreposage_date_presentation, type: Date

  field :dest_prevue_siret,type: String
  field :dest_prevue_nom,type: String
  field :dest_prevue_adresse, type: String
  field :dest_prevue_cp, type: String
  field :dest_prevue_ville, type: String
  field :dest_prevue_tel, type: String
  field :dest_prevue_fax, type: String
  field :dest_prevue_email, type: String
  field :dest_prevue_responsable, type: String
  field :dest_prevue_numcap, type: String
  field :dest_prevue_traitement_prevu, type: String
  field :dest_prevue_rempliepar, type: Integer, default: 1

  field :collecteur_18_siret,type: String
  field :collecteur_18_nom,type: String
  field :collecteur_18_adresse, type: String
  field :collecteur_18_cp, type: String
  field :collecteur_18_ville, type: String
  field :collecteur_18_tel, type: String
  field :collecteur_18_fax, type: String
  field :collecteur_18_email, type: String
  field :collecteur_18_responsable, type: String
  field :mode_transport_18, type: Integer, default: 1
  field :bordereau_limite_validite_18, type: Date #, default: ->{ 10.days.from_now }
  field :transport_multimodal_18, type: Boolean, default: false
  field :recepisse_18, type: String, default: ->{ id }
  field :date_prise_en_charge_18, type: Date #, default: ->{ 10.days.from_now }

  field :collecteur_20_siret,type: String
  field :collecteur_20_nom,type: String
  field :collecteur_20_adresse, type: String
  field :collecteur_20_cp, type: String
  field :collecteur_20_ville, type: String
  field :collecteur_20_tel, type: String
  field :collecteur_20_fax, type: String
  field :collecteur_20_email, type: String
  field :collecteur_20_responsable, type: String
  field :mode_transport_20, type: Integer, default: 1
  field :bordereau_limite_validite_20, type: Date #, default: ->{ 10.days.from_now }
  field :recepisse_20, type: String, default: ->{ id }
  field :date_prise_en_charge_20, type: Date #, default: ->{ 10.days.from_now }

  field :collecteur_21_siret,type: String
  field :collecteur_21_nom,type: String
  field :collecteur_21_adresse, type: String
  field :collecteur_21_cp, type: String
  field :collecteur_21_ville, type: String
  field :collecteur_21_tel, type: String
  field :collecteur_21_fax, type: String
  field :collecteur_21_email, type: String
  field :collecteur_21_responsable, type: String
  field :mode_transport_21, type: Integer, default: 1
  field :bordereau_limite_validite_21, type: Date #, default: ->{ 10.days.from_now }
  field :recepisse_21, type: String #, default: ->{ id }
  field :date_prise_en_charge_21, type: Date#, default: ->{ 10.days.from_now }

  field :date_19, type: Date #, default: ->{ 10.days.from_now }
  field :nom_19, type: String

  #field :destination_ult_siret, type: String
  #field :destination_ult_nom, type: String
  #field :destination_ult_adresse, type: String
  #field :destination_ult_cp, type: String
  #field :destination_ult_ville, type: String
  #field :destination_ult_tel, type: String
  #field :destination_ult_fax, type: String
  #field :destination_ult_mel, type: String
  #field :destination_ult_contact, type: String

  field :mention_titre_reglements_ult, type: String
  field :dechet_conditionnement_ult, type: String
  field :entreposage_provisoire, type: Boolean, default: true
  field :transport_multimodal, type: Boolean, default: false

  field :dechet_nombre_colis_ult, type: Integer
  field :type_quantite_ult, type: String
  field :valorisation_prevue, type: String, default: "R13"
  field :recepisse, type: String, default: "123"
  field :mode_transport, type: Integer, default: 1
  #field :bordereau_limite_validite, type: Date, default: ->{ collecteur.limite_validite }

  field :super_denomination, type: String
  field :immatriculation, type: String
  field :exported, type: Integer, default: 0
  field :bid, type: String
  field :bordereau_date_reception, type: Date

  attr_accessible :id, :bid, :bordereau_id, :producteur_id, :attachment_id, :super_denomination, :produit_id, :bordereau_date_reception,
    :destination_id, :destination_attributes, :collecteur_id, :bon_de_sortie_id,
    :destinataire_siret, :destinataire_nom, :destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_tel, :destinataire_fax,
    :destinataire_responsable, :nomenclature_dechet_code_nomen_c, :nomenclature_dechet_code_nomen_a,
    :libelle, :bordereau_date_transport,
    :bordereau_date_creation, :num_cap, :dechet_denomination, :dechet_consistance, :dechet_nomenclature,
    :dechet_conditionnement, :dechet_nombre_colis, :type_quantite, :bordereau_poids, :emetteur_nom,
    :code_operation, :traitement_prevu, :mention_titre_reglements_ult, :dechet_conditionnement_ult,
    :dechet_nombre_colis_ult, :type_quantite_ult, :bordereau_poids_ult,

    :collecteur_20_siret, :collecteur_20_nom, :collecteur_20_adresse, :collecteur_20_cp, :collecteur_20_ville, :collecteur_20_tel,
    :collecteur_20_fax, :collecteur_20_email, :collecteur_20_responsable, :mode_transport_20, :bordereau_limite_validite_20,
    :recepisse_20,

    :collecteur_21_siret, :collecteur_21_nom, :collecteur_21_adresse, :collecteur_21_cp, :collecteur_21_ville, :collecteur_21_tel,
    :collecteur_21_fax, :collecteur_21_email, :collecteur_21_responsable, :mode_transport_21, :bordereau_limite_validite_21,
    :recepisse_21,

    :collecteur_18_siret, :collecteur_18_nom, :collecteur_18_adresse, :collecteur_18_cp, :collecteur_18_ville, :collecteur_18_tel,
    :collecteur_18_fax, :collecteur_18_email, :collecteur_18_responsable, :mode_transport_18, :bordereau_limite_validite_18,
    :transport_multimodal_18, :recepisse_18,

    :date_prise_en_charge_18, :date_19, :nom_19, :entreposage_poids,

    :dest_prevue_siret, :dest_prevue_nom, :dest_prevue_adresse, :dest_prevue_cp, :dest_prevue_ville, :dest_prevue_tel,
    :dest_prevue_fax, :dest_prevue_email, :dest_prevue_responsable, :dest_prevue_numcap,
    :dest_prevue_rempliepar,

    :entreposage_siret, :entreposage_nom, :entreposage_adresse, :entreposage_cp, :entreposage_ville, :entreposage_tel,
    :entreposage_fax, :entreposage_email, :entreposage_responsable,

  :entreposage_date_presentation, :entreposage_date,
    :destinataire_email, :colllecteur_email, :valorisation_prevue, :entreposage_provisoire, :recepisse,
    :mode_transport, :transport_multimodal, :bordereau_limite_validite,
    #:destination_ult_siret, :destination_ult_nom, :destination_ult_adresse, :destination_ult_cp,
    #:destination_ult_ville, :destination_ult_tel,
    #:destination_ult_contact, :destination_ult_fax, :destination_ult_mel,

    :ligne_flux_siret, :ligne_flux_nom, :ligne_flux_adresse, :ligne_flux_cp, :ligne_flux_ville, :ligne_flux_tel,
    :ligne_flux_fax, :ligne_flux_email, :ligne_flux_responsable, :ligne_flux_conditionnement_ult, :ligne_flux_nombre_colis_ult,

    :emetteur_siret, :emetteur_sortie_nom, :emetteur_adresse, :emetteur_cp, :emetteur_ville, :emetteur_tel,
    :emetteur_fax, :emetteur_email, :emetteur_responsable,

    :ligne_flux_date_remise, :ligne_flux_poids,
    :immatriculation, :exported, :ecodds_id, :ecodds_id_str

    validates_presence_of :collecteur_id, :producteur_id, :produit_id,
    #:collecteur_siret, :collecteur_nom, :collecteur_adresse, :collecteur_cp, :collecteur_ville, 
    #:collecteur_tel, :collecteur_responsable, 
    :bordereau_date_transport,
    :dechet_consistance, :dechet_nomenclature,
    :type_quantite, :emetteur_nom,
    :code_operation, :traitement_prevu, :mode_transport, :transport_multimodal
    #:destination_ult_siret, :destination_ult_nom, :destination_ult_adresse, :destination_ult_cp,
    #:destination_ult_ville, :destination_ult_tel,



    #:libelle,
    #:bordereau_date_creation, 
    #:destinataire_siret, :destinataire_nom,
    #:destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_tel,
    #:destinataire_responsable,




#:ligne_flux_siret,
#:ligne_flux_nom,
#:ligne_flux_adresse,
#:ligne_flux_cp,
#:ligne_flux_ville,
#:ligne_flux_tel,
#:ligne_flux_fax,
#:ligne_flux_email,
#:ligne_flux_responsable,
#:ligne_flux_conditionnement_ult,
#:ligne_flux_nombre_colis_ult,
#:emetteur_siret,
#:emetteur_nom,
#:emetteur_adresse,
#:emetteur_cp,
#:emetteur_ville,
#:emetteur_tel,
#:emetteur_fax,
#:emetteur_email,
#:emetteur_responsable

  validates_presence_of :mention_titre_reglements_ult, :dechet_conditionnement_ult,
    :dechet_nombre_colis_ult, :type_quantite_ult, :bordereau_poids_ult, :entreposage_provisoire,

    :collecteur_20_siret, :collecteur_20_nom, :collecteur_20_adresse, :collecteur_20_cp, :collecteur_20_ville, :collecteur_20_tel,
    :collecteur_20_fax, :collecteur_20_email, :collecteur_20_responsable, :mode_transport_20, :bordereau_limite_validite_20,
    :recepisse_20,

    :collecteur_21_siret, :collecteur_21_nom, :collecteur_21_adresse, :collecteur_21_cp, :collecteur_21_ville, :collecteur_21_tel,
    :collecteur_21_fax, :collecteur_21_email, :collecteur_21_responsable, :mode_transport_21, :bordereau_limite_validite_21,
    :recepisse_21,

    :collecteur_18_siret, :collecteur_18_nom, :collecteur_18_adresse, :collecteur_18_cp, :collecteur_18_ville, :collecteur_18_tel,
    :collecteur_18_fax, :collecteur_18_email, :collecteur_18_responsable, :mode_transport_18, :bordereau_limite_validite_18,
    :transport_multimodal_18, :recepisse_18,

    :date_prise_en_charge_18, :date_19, :nom_19,

    :dest_prevue_siret, :dest_prevue_nom, :dest_prevue_adresse, :dest_prevue_cp, :dest_prevue_ville, :dest_prevue_tel,
    :dest_prevue_fax, :dest_prevue_email, :dest_prevue_responsable,
    :dest_prevue_rempliepar,

    :entreposage_siret, :entreposage_nom, :entreposage_adresse, :entreposage_cp, :entreposage_ville, :entreposage_tel,
    :entreposage_fax, :entreposage_email, :entreposage_responsable,

    :entreposage_date,
    :entreposage_date_presentation,
    :entreposage_poids,
    :bordereau_poids_ult,#, numericality: true,
    unless: -> { new_record? || entreposage_provisoire == false }


  # NOUVEAU eBSD AVEC DESTINATAIRE_ID

  attr_accessible :destinataire_id
  validates_presence_of :destinataire_id
  validates_presence_of :dechet_conditionnement
  #validates_presence_of :bordereau_id
  validates_presence_of :dechet_nombre_colis, #, :bordereau_poids,
    unless: -> { new_record? || is_nouveau?  }
  #validates_numericality_of :bordereau_poids, greater_than: 0,
    #unless: -> { new_record?  || is_nouveau? }

  def self.en_cours_stock date = Date.today
    map = %Q{
      function() {
        emit(this.dechet_nomenclature, this.bordereau_poids);
      }
    }.squish

    reduce = %Q{
      function(key, countObjVals) {
        var result = 0;
        countObjVals.forEach(function(value) {
          result += value;
        });
        return result;
      }
    }.squish
    results = ebsdds.where(created_at: date.beginning_of_day..date.end_of_day).and(status: :complet).map_reduce(map, reduce).out(inline: true)
    #results.entries.map{ |i| [DechetDenomination[i["_id"]][3..-1], i["value"].to_i ] }
  end


  validates_presence_of :ecodds_id,
    if: -> { !producteur.nil? && producteur.nom =~ /eco dds/i }
  validates :ecodds_id, length: { is: 8,
    wrong_length: ": la longueur du numéro doit être de %{count} chiffres" },
    if: -> { !producteur.nil? && producteur.nom =~ /eco dds/i }

  validates_presence_of :recepisse,# :bordereau_limite_validite,
    if: -> { self[:mode_transport] == 1 }

  validates_presence_of :immatriculation,# :bordereau_limite_validite,
    if: -> { !new_record? && self.collecteur.nom == "TRIALP" }

  def is_entreposage_provisoire?
    entreposage_provisoire || false
  end
  def complete_new
    # evite les problèmes en cas d'import
    unless self[:status] == :incomplet
      self[:libelle] = produit.nom
      self[:dechet_denomination] = produit.code_rubrique.to_i
      self[:status] = :nouveau
    end
    self[:bordereau_date_creation] = Time.now
    self[:bordereau_id] = "#{id}" #"#{Date.today.strftime("%Y%m%d")}#{"%04d" % (Ebsdd.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count + 1) }" if self[:status] == :nouveau
    self[:bid] = "#{id}" #long_bid
    set_num_cap
    set_infos_from_collecteur
  end
  def is_nouveau?
    status == :nouveau
  end
  def is_clos?
    status == :clos
  end
  def is_complete?
    status == :complet
  end
  def is_incomplete?
    status == :incomplet
  end
  def self.normalize_float float
    str = "%.0f" % float
    if str.size > 5 && str !=~ /\A0/
      "0#{str}"
    else
      str
    end
  end
  def long_bid
    lbid = read_attribute(:bordereau_id)
    unless lbid.nil?
      "%.0f" % lbid
    else
      "#"
    end
  end
  def short_bid
    #self[:bid].gsub(Date.today.strftime("%Y%m%d"), "") if self[:bid] =~ /\A#{Date.today.strftime("%Y")}/
    if self[:bid] =~ /\A1/
      long_bid.gsub('1000000', "")
    else
      self[:bid]
    end
  end
  def denomination_cadre_3
    produit.nom
  end
  def denomination_ecodds
      self[:super_denomination] = produit.index if super_denomination.nil?
      "#{"%02d" % produit.index}-#{produit.nom}"
  end
  def denomination_cadre_4
    produit.mention
  end
  #def status_label
    #labels = {
      #nouveau: "Nouveau",
      #en_attente: "Attente Réception",
      #attente_sortie: "En stock",
      #clos: "Archivé",
      #complet: "Complet",
      #incomplet: "Incomplet"
    #}
    #if label.has_key status
      #label[status]
    #else
      #"ERREUR STATUT"
    #end
  #end
  def to_csv
    CSV.generate({:col_sep => ";"}) do |csv|
      column_names = attributes.keys
      csv << column_names
      csv << attributes.values_at(*column_names)
    end
  end
  def ecodds_label
    if is_ecodds
      "<label class='label label-primary'>ECODDS</label>"
    else
      "<label class='label label-default'>Normal</label>"
    end
  end
  def default_ecodds_id
    "#{Time.now.strftime("%y")}#{id[-6..-1]}"
  end
  def inc_export by = 1
    inc(:exported, by)
  end
  def annexe_2_to_csv
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do | csv |
      csv << ["00", ecodds_id, bordereau_id, nil]
      csv << ["01", 4, emetteur_siret, emetteur_nom, emetteur_adresse, emetteur_cp, emetteur_ville, emetteur_tel, emetteur_fax, emetteur_email, emetteur_responsable, nil]
      csv << ["02", :code_ligne_flux_original, bordereau_id, ligne_flux_siret, ligne_flux_nom, ligne_flux_adresse, ligne_flux_cp, ligne_flux_ville, ligne_flux_tel,
              ligne_flux_fax, ligne_flux_email, ligne_flux_responsable, ligne_flux_conditionnement_ult, 1, produit.denomination_ecodds,
              type_quantite_ult, poids_en_tonnes_ult, ligne_flux_date_remise ,nil]
      # TODO: Attention à la dernière ligne qui contient des infos prise dans les autres cadres
    end
  end
  def self.to_multi params
    if params.has_key?(:ebsdds) && params[:ebsdds].class == Array && params[:ebsdds].any?
      ebsdds = Ebsdd.in(ecodds_id: params[:ebsdds])
      ebsdds.map do | ebsdd |
        ebsdd.inc_export
        ebsdd.to_ebsdd
      end.join
    end
  end
  def to_ebsdd
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      csv << ["00", ecodds_id.to_s.truncate(8, omission: ""), bid.to_s.truncate(35, omission: ""), nil]
      csv << ["01", 4, producteur.try(:siret).try(:truncate, 14, omission: ""), producteur.try(:nom).try(:truncate, 60, omission: ""), producteur.try(:adresse).try(:truncate, 100, omission: ""),
                producteur.try(:cp).try(:truncate, 5, omission: ""), producteur.try(:ville).try(:truncate, 45, omission: ""), producteur.try(:tel).try(:truncate, 35, omission: ""), 
                producteur.try(:fax).try(:truncate, 35, omission: ""), producteur.try(:email).try(:truncate, 50, omission: ""),
                producteur.try(:responsable).try(:truncate, 35, omission: ""), nil]
      csv << ["02", (entreposage_provisoire ? 1 : 0), (destinataire.siret || "").truncate(14, omission: ""), (destinataire.nom || "").truncate(60, omission: ""), (destinataire.adresse || "").truncate(100, omission: ""), (destinataire.cp || "").truncate(5, omission: ""), (destinataire.ville || "").truncate(45, omission: ""), (destinataire.tel || "").truncate(35, omission: ""), (destinataire.fax || "").truncate(35, omission: ""), (destinataire.email || "").truncate(50, omission: ""), (destinataire.responsable || "").truncate(35, omission: ""), num_cap.truncate(35, omission: ""), "R13", nil]
      csv << ["03", produit.code_rubrique.to_s.truncate(6, omission: ""), 1, produit.denomination_ecodds.truncate(100, omission: ""), dechet_consistance.to_s.truncate(10, omission: ""), nil ]
      csv << ["04", produit.mention.truncate(255, omission: ""), nil ]
      csv << ["05", dechet_conditionnement.truncate(6, omission: ""), dechet_nombre_colis.to_s.truncate(6, omission: ""), nil ]
      csv << ["06", type_quantite.truncate(1, omission: ""), poids_en_tonnes.truncate(8, omission: ""), nil ]
      csv << ["08", (collecteur.siret || "").truncate(14, omission: ""), (collecteur.nom || "").truncate(60, omission: ""),
             (collecteur.adresse || "").truncate(100, omission: ""), (collecteur.cp || "").truncate(5, omission: ""),
             (collecteur.ville || "").truncate(45, omission: ""),
             (collecteur.tel || "").truncate(35, omission: ""), (collecteur.fax || "").truncate(35, omission: ""),
             (collecteur.email || "").truncate(50, omission: ""), (collecteur.responsable || "").truncate(35, omission: ""),
             (collecteur.mode_transport == 1 ? collecteur.recepisse : nil).truncate(35, omission: ""),
             (collecteur.mode_transport == 1 ? collecteur.cp : nil),
             (collecteur.mode_transport == 1 ? collecteur.limite_validite.strftime("%Y%m%d") : nil), (collecteur.mode_transport ? 1 : 0),
             bordereau_date_transport.strftime("%Y%m%d"), (transport_multimodal ? 1 : 0), nil ]
      csv << ["09", emetteur_nom.truncate(60, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil]
      csv << ["10", (destinataire.siret || "").truncate(14, omission: ""), (destinataire.nom || "").truncate(60, omission: ""), 
              (destinataire.adresse || "").truncate(100, omission: ""), (destinataire.cp || "").truncate(5, omission: ""),
              (destinataire.ville || "").truncate(45, omission: ""), (destinataire.responsable || "").truncate(35, omission: ""),
              poids_en_tonnes.truncate(8, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), 1, nil,
              (destinataire.responsable || "").truncate(35, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil ]
      csv << ["11", code_operation, CodeDr[code_operation].truncate(35, omission: ""), (destinataire.responsable || "").truncate(60, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil]
      csv << ["12", traitement_prevu.truncate(3, omission: ""), destination.siret.truncate(14, omission: ""), destination.nom.truncate(60, omission: ""), destination.adresse.truncate(100, omission: ""), destination.cp.truncate(5, omission: ""), destination.ville.truncate(45, omission: ""), destination.tel.truncate(35, omission: ""), destination.fax.truncate(35, omission: ""), destination.email.truncate(50, omission: ""), destination.responsable.truncate(35, omission: "") , nil]
      if entreposage_provisoire
        csv << ["13", entreposage_siret.truncate(14, omission: ""), entreposage_nom.truncate(60, omission: ""), (entreposage_adresse || "").truncate(100, omission: ""), entreposage_cp.truncate(5, omission: ""), entreposage_ville.truncate(45, omission: ""), (entreposage_type_quantite || "").truncate(1, omission: ""), poids_en_tonnes2(entreposage_poids).truncate(8, omission: ""), entreposage_date.strftime("%Y%m%d"), 1, nil, entreposage_date_presentation.strftime("%Y%m%d"), nil ]
        csv << ["14", dest_prevue_siret.truncate(14, omission: ""), dest_prevue_nom.truncate(60, omission: ""), 
                dest_prevue_adresse.truncate(100, omission: ""), dest_prevue_cp.truncate(5, omission: ""),
                dest_prevue_ville.truncate(45, omission: ""), dest_prevue_tel.truncate(35, omission: ""),
                dest_prevue_fax.truncate(35, omission: ""), dest_prevue_email.truncate(50, omission: ""),
                dest_prevue_responsable.truncate(35, omission: ""),
                (dest_prevue_numcap || "").truncate(35, omission: ""),
                "R13", dest_prevue_rempliepar, nil ]
        csv << ["15", DechetNomenclature[mention_titre_reglements_ult],  nil ]
        csv << ["16", dechet_conditionnement_ult, dechet_nombre_colis_ult, nil ]
        csv << ["17", type_quantite_ult, poids_en_tonnes_ult, nil ]
        csv << ["18", collecteur_18_siret, recepisse_18, collecteur_18_cp[0..1], bordereau_limite_validite_18.strftime("%Y%m%d"), collecteur_18_nom, collecteur_18_adresse, collecteur_18_cp, collecteur_18_ville, mode_transport_18, date_prise_en_charge_18.strftime("%Y%m%d"), collecteur_18_tel, collecteur_18_fax, collecteur_18_email, collecteur_18_responsable, transport_multimodal_18, nil ]
        csv << ["19", nom_19, date_19.strftime("%Y%m%d"), nil ]
      end
      if transport_multimodal || transport_multimodal_18
        csv << ["20", collecteur_20_siret, recepisse_20, collecteur_20_cp[0..1], bordereau_limite_validite_20.strftime("%Y%m%d"), mode_transport_20, collecteur_20_nom, collecteur_20_adresse, collecteur_20_cp, collecteur_20_ville, date_prise_en_charge_20.strftime("%Y%m%d"), collecteur_20_tel, collecteur_20_fax, collecteur_20_email, collecteur_20_responsable, nil ]
        csv << ["21", collecteur_21_siret, recepisse_21, collecteur_21_cp[0..1], bordereau_limite_validite_21.strftime("%Y%m%d"), mode_transport_21, collecteur_21_nom, collecteur_21_adresse, collecteur_21_cp, collecteur_21_ville, date_prise_en_charge_21.strftime("%Y%m%d"), collecteur_21_tel, collecteur_21_fax, collecteur_21_email, collecteur_21_responsable, nil ]
      end
    end
  end

  def self.has_every_bsd_completed?
    Ebsdd.where(status: :incomplet).exists?
  end
  def ecodds_old_nb
    ["100000053072",
     "100000053074",
     "100000053078",
     "100000053080",
     "100000053075",
     "100000053077",
     "100000053106",
     "100000053108",
     "100000053095",
     "100000053096",
     "100000053097",
     "100000053098",
     "100000053102",
     "100000053103",
     "100000053104",
     "100000053110",
     "100000053112",
     "100000053114"]
  end
  def self.import2(file)
    attrs = [
      :producteur_siret, :producteur_nom, :producteur_adresse,
      :producteur_cp, :producteur_ville, :producteur_tel,
      :producteur_fax, :producteur_email, :producteur_responsable,
    ]
    result, errors = [], []
    spreadsheet = open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.first
    if spreadsheet.last_row > 1
      checksum  = Digest::MD5.hexdigest(file.read)
      unless Attachment.where(checksum: checksum).exists?
        @document = Attachment.new( { attachment: file, checksum: checksum } )
        #@document.attachment = file
        if @document.save!
          result = created_from_spreadsheet spreadsheet, attrs
          @document[:failed] = result[:failed]
          @document[:total] = result[:total]
          @document[:exec_time] = result[:exec_time]
          @document[:producteurs] = result[:producteurs]
          @document.save!
        else
          errors << "Impossible de sauvegarder le document. Veuillez transmettre ce document à votre administrateur pour analyse."
        end
      else
        errors << "Un fichier contenant les mêmes données existe déjà. Veuillez importer un autre fichier."
      end
    end
    errors
  end

  def self.producteur_attr_indexes attr, headers
    h = headers.reduce( {} ) do | h, _i |
      unless _i.nil?
        i = _i.downcase.strip
        attr.each do | a |
          h[a] = headers.index(_i) if a =~ /#{i}/
        end
      end
      h
    end
    h
  end

  def self.created_from_spreadsheet spreadsheet, attrs
    header              = spreadsheet.row(1).map{ |h| h.downcase.strip unless h.nil? }
    bordereau_id_column = header.index("bordereau_id")
    producteur_attrs = producteur_attr_indexes(attrs, header)
    failed, start, total, new_producteurs = [], Time.now, 0, []
    dest_id = Destinataire.first
    clctr = Collecteur.first
    unless bordereau_id_column.nil? || producteur_attrs.empty?
      (2..spreadsheet.last_row).each do | i |
        total += 1
        row = spreadsheet.row(i)
        bordereau_id = row[bordereau_id_column]
        producteur_nom = row[producteur_attrs[:producteur_nom]].squish
        next unless producteur_nom =~ /ECO DDS/i
        producteur = if Producteur.where(nom: producteur_nom).exists?
          Producteur.find_by(nom: producteur_nom)
        else
          new_producteur = import_new_producteur row, producteur_attrs
          p = Producteur.create( new_producteur )
          new_producteurs << p.id
          p
        end
        unless Ebsdd.where({bordereau_id: bordereau_id } ).exists?
          ebsdd = Ebsdd.new

          row.each_with_index do | cell, index |
              cur_cell = if cell.is_a? Float
                           cell.to_i
                         elsif cell.is_a? String
                           cell.squish
                         else
                           cell
                         end
            cur_header = header[ index ]
            ebsdd[cur_header.to_sym] = cur_cell unless cur_header.nil? || producteur_attrs.keys.include?(cur_header.to_sym)
          end
          ebsdd.line_number = i
          ebsdd.destinataire = dest_id
          ebsdd.collecteur = clctr
          ebsdd.status = :incomplet
          ebsdd.exported = 0
          ebsdd.write_attribute :bid, ebsdd.long_bid
          ebsdd.producteur = producteur
          ebsdd.attachment_id =  @document.id
          ebsdd.save(validate: false)
        else
          failed << {id: bordereau_id, line: i }
        end
      end
    #else
      #out[:errors] << "Impossible de trouver le numéro de bordereau dans le document. Veuillez transmettre ce document à votre administrateur pour analyse."
    end
    {failed: failed, exec_time: Time.now - start, total: total, producteurs: new_producteurs}
  end
  def self.import_new_producteur row, producteur_attrs
    producteur_attrs.reduce({}) do  | h, (_k,v) |
      k = _k.to_s.gsub("producteur_","").to_sym
      if row[v].nil?
        h[k] = nil
      elsif row[v].is_a? Float
        h[k] = normalize_float(row[v])
      else
        h[k] = row[v].squish
      end
      h
    end
  end
  def prev_status
    case self[:status]
    when :en_attente
      set(:status, :nouveau)
    when :attente_sortie
      set(:status, :en_attente)
    when :clos
      set(:status, :attente_sortie)
    end
  end
  def next_status
    case self[:status]
    when :attente_sortie
      set(:status, :clos)
    when :en_attente
      set(:status, :attente_sortie)
    when :nouveau
      set(:status, :en_attente)
    end
  end
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  def self.multiebsdd_search min, max
    #@ebsdds = Ebsdd.where(:status.in => [:nouveau, :en_attente, :complet, :attente_sortie, :clos],
                            #is_ecodds: true,
                            #:bordereau_poids.ne => nil)
                #.between(bordereau_date_transport: min..max).order_by(bordereau_date_transport: 1) #.paginate(page: params[:page], per_page: 15)
    @ebsdds = Ebsdd.between(bordereau_date_transport: min..max).where(is_ecodds: true).order_by(bordereau_date_transport: 1).and( :bordereau_poids.ne => nil) # }, {:pesees.gt => 0})
  end
  def self.search params
    if params.has_key?(:status)
      params[:status] = "closs" if params[:status] == "clos"
      Ebsdd.where(status: params[:status].singularize) #.order_by(created_at: :desc)
    else
      Ebsdd.all #.order_by(created_at: :desc)
    end
  end

  def normalize
    self[:recepisse] = collecteur.recepisse unless read_attribute(:mode_transport) == 1
    [ :destinataire_email].each do | attr |
      self[attr] = nil if read_attribute(attr).blank?
    end
    [ :destinataire_tel, :destinataire_fax, :ligne_flux_fax, :ligne_flux_tel, :emetteur_fax, :emetteur_tel ].each do | attr |
      unless self[attr].nil?
        if self[attr].is_a? Integer
          self[attr] = "0#{self[attr]}" if self[attr].size == 9 && self[attr].is_a
        else
          begin
          self[attr].gsub!(/ /, "")
          rescue
            binding.pry
          end
        end
      end
    end
    [ :destinataire_siret, :collecteur_siret, :ligne_flux_siret, :emetteur_siret ].each do | attr |
      unless read_attribute(attr).nil?
        self[attr].gsub!(/\s/, "")
      end
    end
  end
  def status_label
    l = "<label class='label label-%s'>%s</label>"
    case status
    when :complet
      l % ["primary", "Complet"]
    when :nouveau
      l % ["default", "Nouveau"]
    when :en_attente
      l % ["info", "Attente Réception"]
    when :attente_sortie
      l % ["warning", "En Stock"]
    when :incomplet
      l % ["danger", "Incomplet"]
    when :clos
      l % ["success", "Archivé"]
    end
  end
  def num_cap_auto
    unless dechet_conditionnement.nil?
      y = Time.now.strftime("%Y")
      s = unless producteur.siret.nil?
            producteur.siret.gsub(/ |-|\./, "")[0..8]
          else
            producteur.nom[0..8]
          end
      p = case produit.index.to_i
      when 1
        "PE"
      when 2
        "ES"
      when 3
        "AE"
      when 4
        "SO"
      when 5
        "PH"
      when 6
        "FH"
      when 7
        "AC"
      when 8
        "BA"
      when 9
        "CO"
      else
        libelle.try(:slice, 0,2).try(:upcase) || "XX"
      end

      "#{y}#{p}#{s}"
    end
  end
  def self.seuils
    map = %Q{
      function() {
        emit( this.produit_id, this.bordereau_poids );
      };
    }

    reduce = %Q{
      function(id, poids) {
        return Array.sum(poids);
      };
    }
    mr = Ebsdd.where(status: :attente_sortie).map_reduce(map, reduce).out(inline: true)
    mr.entries.reduce([]) do |a, e|
      #binding.pry
      produit = Produit.find e["_id"]
      a << { id: produit.id, nom: produit.nom, seuil: produit.seuil_alerte, poids: e["value"], type: produit.type, pretty_poids: "#{e["value"].to_s.gsub('.', ',')} kg" }
      a
    end.sort_by do | h |
      h[:nom]
    end
  end
  def self.camions date_min = Date.today.beginning_of_month.beginning_of_day, date_max = Date.today.end_of_month.end_of_day
    date_min, date_max = date_max, date_min if date_min > date_max
    date_min = date_min.beginning_of_day
    date_max = date_max.end_of_day
    map = %Q{
      function() {
        emit( this.immatriculation, this.bordereau_poids );
      };
    }

    reduce = %Q{
      function(id, poids) {
        return Array.sum(poids);
      };
    }
    mr = Ebsdd.in(status: [:attente_sortie, :clos, :complet]).between(bordereau_date_transport: date_min..date_max).map_reduce(map, reduce).out(inline: true)

    data = mr.entries.reduce([]) do |a, e|
      immat = Immatriculation.find e["_id"]
      val = immat.nil? ? "Immaticulation inconnue" : immat.valeur
      a << { nom: val, poids: e["value"] }
      a
    end.sort_by do | h |
      h[:poids]
    end

    {
      du: date_min.strftime("%d/%m/%Y"),
      au: date_max.strftime("%d/%m/%Y"),
      data: data
    }
  end
  def self.quantites date_min = Date.today.beginning_of_month.beginning_of_day, date_max = Date.today.end_of_month.end_of_day
    date_min, date_max = date_max, date_min if date_min > date_max
    date_min = date_min.beginning_of_day
    date_max = date_max.end_of_day

    map = %Q{
      function() {
        emit( this.produit_id, this.bordereau_poids );
      };
    }.squish

    reduce = %Q{
      function(id, poids) {
        return Array.sum(poids);
      };
    }.squish
    # Conditions :
    # - dont la date de reception est comprise entre les dates passées en paramètre
    mr = Ebsdd.in(status: [:attente_sortie, :clos]).between(bordereau_date_transport: date_min..date_max).map_reduce(map, reduce).out(inline: true)
    data = mr.entries.reduce([]) do |a, e|
      produit = Produit.find e["_id"]
      a << { id: produit.id, nom: produit.nom, poids: e["value"] }
      a
    end.sort_by do | h |
      h[:nom]
    end
    {
      du: date_min.strftime("%d/%m/%Y"),
      au: date_max.strftime("%d/%m/%Y"),
      data: data
    }
  end
  def self.quantites_to_csv date_min = Date.today.beginning_of_month.beginning_of_day, date_max = Date.today.end_of_month.end_of_day
    date_min, date_max = date_max, date_min if date_min > date_max
    date_min = date_min.beginning_of_day
    date_max = date_max.end_of_day

    map = %Q{
      function() {
        emit( this.produit_id, this.bordereau_poids );
      };
    }

    reduce = %Q{
      function(id, poids) {
        return Array.sum(poids);
      };
    }
    # Conditions :
    # - dont la date de reception est comprise entre les dates passées en paramètre
    mr = Ebsdd.in(status: [:attente_sortie, :clos]).between(bordereau_date_transport: date_min..date_max).map_reduce(map, reduce).out(inline: true)
    data = mr.entries.reduce([]) do |a, e|
      produit = Produit.find e["_id"]
      a << { nom: produit.nom, poids: e["value"], codedr: produit.code_rubrique, ecodds: produit.is_ecodds ? "1" : "0", ddm: produit.is_ddm ? "1" : "0", ddi: produit.is_ddi ? "1" : "0" }
      a
    end.sort_by do | h |
      h[:nom]
    end

    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      csv << ["Nom du déchet","Code DR", "Poids (tonnes)", "EcoDDS", "DDM", "DDI"]
      data.each do | qte |
        csv << [qte[:nom], qte[:codedr], qte[:poids], qte[:ecodds], qte[:ddm], qte[:ddi]]
      end
    end
  end
  def self.camions_to_csv date_min, date_max
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      csv << ["Nom du déchet", "Poids (tonnes)"]
      camions(date_min, date_max)[:data].each do | qte |
        csv << [qte[:nom], qte[:poids]]
      end
    end
  end

end
  #p.ebsdds.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)


#map = %Q{
  #function() {
    #emit({nom: this.nom, siret: this.siret}, { count: 1 });
  #}
#}

#reduce = %Q{
  #function(key, countObjVals) {
  #}
#}
#map = %Q{
  #function() {
    #var count = 1;
    #if (this.siret == null) {
      #count = 0;
    #}
    #emit(this.nom, { count: count });
  #}
#}

#reduce = %Q{
  #function(key, countObjVals) {
    #var result = 0;
    #countObjVals.forEach(function(value) {
      #result += value.count;
    #});
    #return { count: result };
  #}
#}
#map = %Q{
  #function() {
    #var count = 1;
    #if (this.siret == null) {
      #count = 0;
    #}
    #emit(this.nom, { count: count });
  #}
#}

#reduce = %Q{
  #function(key, countObjVals) {
    #var result = 0;
    #countObjVals.forEach(function(value) {
      #result += value.count;
    #});
    #return { count: result };
  #}
#}
#c = Producteur.map_reduce(map, reduce).out(inline: true)
#c.reduce({}){ |h, e| h[e["_id"]] = e["value"]["count"] if e["value"]["count"] > 1 ; h }
##Producteur.map_reduce(map, reduce).out(inline: true).finalize(func).each{ |d| puts d}.count
#reduce = %Q{
  #function(key, countObjVals) {
    #var result = { count: 0 };
    #countObjVals.forEach(function(value) {
      #result.count += value.count;
    #});
    #return result;
  #}
#}

#func = %Q{

  #function(key, value) {
    #if(value.count > 1) {
      #return value;
    #}
  #}
#}

