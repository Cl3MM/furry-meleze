# encoding: utf-8

class Ebsdd # < ActiveRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.per_page
    15
  end

#TODO :
  #Recherche :
    #Critères :
      #Type de déchet (pateux, inflamable)
      #Date de réception (date du cadre 8 bordereau_date_transport)
      #Producteur du déchet
      #Destination du déchet
      #Numéro bordereau_id ou ecodds_id
      #Intervalle de temps (du 26 Juillet au 31 Septembre)

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

  before_create :normalize, :set_status
  before_update :set_status

  def set_status
    if self[:status] == :import
      self[:status] = :incomplet
    elsif self[:status] = :incomplet
      self[:status] = :complet
    end
  end

  belongs_to :productable, polymorphic: true, class_name: "Producteur"#, inverse_of: :producteur
  belongs_to :collectable, polymorphic: true, class_name: "Producteur"
  belongs_to :destination, inverse_of: :destination
  belongs_to :attachment #, :inverse_of => :ebsdds
  accepts_nested_attributes_for :productable
  accepts_nested_attributes_for :collectable
  accepts_nested_attributes_for :destination
  attr_accessible :id, :_id

  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}#{"%04d" % Ebsdd.count}" }
  field :ecodds_id, type: Integer, default: ->{ default_ecodds_id }
  field :status, type: Symbol, default: :incomplet
  field :line_number, type: Integer
  field :bordereau_id, type: Integer
  field :bordereau_poids, type: Float
  field :bordereau_poids_ult, type: Float

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
  field :bordereau_poids, type: Integer
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
  field :bordereau_limite_validite_18, type: Date, default: ->{ 10.days.from_now }
  field :transport_multimodal_18, type: Boolean, default: false
  field :recepisse_18, type: String, default: ->{ id }
  field :date_prise_en_charge_18, type: Date, default: ->{ 10.days.from_now }

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
  field :bordereau_limite_validite_20, type: Date, default: ->{ 10.days.from_now }
  field :recepisse_20, type: String, default: ->{ id }
  field :date_prise_en_charge_20, type: Date, default: ->{ 10.days.from_now }

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
  field :bordereau_limite_validite_21, type: Date, default: ->{ 10.days.from_now }
  field :recepisse_21, type: String, default: ->{ id }
  field :date_prise_en_charge_21, type: Date, default: ->{ 10.days.from_now }

  field :date_19, type: Date, default: ->{ 10.days.from_now }
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
  field :recepisse, type: String, default: ->{ id }
  field :mode_transport, type: Integer, default: 1
  field :bordereau_limite_validite, type: Date, default: ->{ 10.days.from_now }

  field :immatriculation, type: String

  attr_accessible :id, :bordereau_id, :productable_attributes, :productable_id, :attachment_id,
    :destination_id, :destination_attributes, :collectable_id, :collectable_attributes,
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
    :ecodds_id,
    :immatriculation

    validates_presence_of :bordereau_id, :productable_id,
    :destinataire_siret, :destinataire_nom,
    :destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_tel,
    :destinataire_responsable,
    #:collecteur_siret, :collecteur_nom, :collecteur_adresse, :collecteur_cp, :collecteur_ville, 
    #:collecteur_tel, :collecteur_responsable, 
    :libelle,
    :bordereau_date_transport, :bordereau_poids,
    :bordereau_date_creation, :num_cap, :dechet_denomination, :dechet_consistance, :dechet_nomenclature,
    :dechet_conditionnement, :dechet_nombre_colis, :type_quantite, :bordereau_poids, :emetteur_nom,
    :code_operation, :traitement_prevu, :mode_transport, :transport_multimodal,
    #:destination_ult_siret, :destination_ult_nom, :destination_ult_adresse, :destination_ult_cp,
    #:destination_ult_ville, :destination_ult_tel,
    :ecodds_id, :immatriculation

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

    :date_prise_en_charge_18, :date_19, :nom_19, :entreposage_poids,

    :dest_prevue_siret, :dest_prevue_nom, :dest_prevue_adresse, :dest_prevue_cp, :dest_prevue_ville, :dest_prevue_tel,
    :dest_prevue_fax, :dest_prevue_email, :dest_prevue_responsable,
    :dest_prevue_rempliepar,

    :entreposage_siret, :entreposage_nom, :entreposage_adresse, :entreposage_cp, :entreposage_ville, :entreposage_tel,
    :entreposage_fax, :entreposage_email, :entreposage_responsable,

  :entreposage_date,
  :entreposage_date_presentation, 
    unless: -> { new_record? || entreposage_provisoire == false }

  validates :entreposage_poids, :bordereau_poids_ult, numericality: true, unless: -> { new_record? || entreposage_provisoire == false }
  validates :bordereau_poids, numericality: true
  validates_presence_of :recepisse,# :bordereau_limite_validite,
    if: -> { self[:mode_transport] == 1 }

  def is_entreposage_provisoire?
    entreposage_provisoire || false
  end
  def poids_en_tonnes2 attr
    unless attr.nil?
      "#{"%08.3f" % (attr.to_f / 1000.0) }" 
    else
      ""
    end
  end
  def poids_en_tonnes
    "#{"%08.3f" % (read_attribute(:bordereau_poids) / 1000.0) }"
  end
  def poids_en_tonnes_ult
    "#{"%08.3f" % (read_attribute(:bordereau_poids_ult) / 1000.0) }" unless bordereau_poids_ult.nil?
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
  def bid
    bid = read_attribute(:bordereau_id)
    unless bid.nil? 
      "%.0f" % bid
    else
      "#"
    end
  end
  def short_bid
    bid.gsub('1000000', "")
  end
  def to_csv
    CSV.generate({:col_sep => ";"}) do |csv|
      column_names = attributes.keys
      csv << column_names
      csv << attributes.values_at(*column_names)
    end
  end
  def default_ecodds_id
    "#{Time.now.strftime("%y")}#{id[-6..-1]}"
  end
  def annexe_2_to_csv
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do | csv |
      csv << ["00", ecodds_id, bordereau_id, nil]
      csv << ["01", 4, emetteur_siret, emetteur_nom, emetteur_adresse, emetteur_cp, emetteur_ville, emetteur_tel, emetteur_fax, emetteur_email, emetteur_responsable, nil]
      csv << ["02", :code_ligne_flux_original, bordereau_id, ligne_flux_siret, ligne_flux_nom, ligne_flux_adresse, ligne_flux_cp, ligne_flux_ville, ligne_flux_tel,
              ligne_flux_fax, ligne_flux_email, ligne_flux_responsable, ligne_flux_conditionnement_ult, 1, DechetDenomination[dechet_denomination],
              type_quantite_ult, poids_en_tonnes_ult, ligne_flux_date_remise ,nil]
      # TODO: Attention à la dernière ligne qui contient des infos prise dans les autres cadres
    end
  end
  def to_ebsdd
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      csv << ["00", ecodds_id.to_s.truncate(8, omission: ""), bordereau_id.to_s.truncate(35, omission: ""), nil]
      csv << ["01", 4, productable.siret.truncate(14, omission: ""), productable.nom.truncate(60, omission: ""), productable.adresse.truncate(100, omission: ""), productable.cp.truncate(5, omission: ""), productable.ville.truncate(45, omission: ""), productable.tel.truncate(35, omission: ""), productable.fax.truncate(35, omission: ""), productable.email.truncate(50, omission: ""), productable.responsable.truncate(35, omission: ""), nil]
      csv << ["02", (entreposage_provisoire ? 1 : 0), (destinataire_siret || "").truncate(14, omission: ""), (destinataire_nom || "").truncate(60, omission: ""), (destinataire_adresse || "").truncate(100, omission: ""), (destinataire_cp || "").truncate(5, omission: ""), (destinataire_ville || "").truncate(45, omission: ""), (destinataire_tel || "").truncate(35, omission: ""), (destinataire_fax || "").truncate(35, omission: ""), (destinataire_email || "").truncate(50, omission: ""), (destinataire_responsable || "").truncate(35, omission: ""), num_cap.truncate(35, omission: ""), "R13", nil]
      csv << ["03", dechet_denomination.to_s.truncate(6, omission: ""), 1, DechetDenomination[dechet_denomination].truncate(100, omission: ""), dechet_consistance.to_s.truncate(10, omission: ""), nil ]
      csv << ["04", DechetNomenclature[dechet_denomination].truncate(255, omission: ""), nil ]
      csv << ["05", dechet_conditionnement.truncate(6, omission: ""), dechet_nombre_colis.to_s.truncate(6, omission: ""), nil ]
      csv << ["06", type_quantite.truncate(1, omission: ""), poids_en_tonnes.truncate(8, omission: ""), nil ]
      csv << ["08", (collectable.siret || "").truncate(14, omission: ""), (collectable.nom || "").truncate(60, omission: ""), (collectable.adresse || "").truncate(100, omission: ""), (collectable.cp || "").truncate(5, omission: ""), (collectable.ville || "").truncate(45, omission: ""), (collectable.tel || "").truncate(35, omission: ""), (collectable.fax || "").truncate(35, omission: ""), (collectable.email || "").truncate(50, omission: ""), (collectable.responsable || "").truncate(35, omission: ""), (mode_transport == 1 ? recepisse : nil).truncate(35, omission: ""), (mode_transport == 1 ? collectable.cp : nil), (mode_transport == 1 ? bordereau_limite_validite.strftime("%y%m%d") : nil), (mode_transport ? 1 : 0), bordereau_date_transport.strftime("%y%m%d"), (transport_multimodal ? 1 : 0), nil ]
      csv << ["09", emetteur_nom.truncate(60, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil]
      csv << ["10", (destinataire_siret || "").truncate(14, omission: ""), (destinataire_nom || "").truncate(60, omission: ""), (destinataire_adresse || "").truncate(100, omission: ""), (destinataire_cp || "").truncate(5, omission: ""), (destinataire_ville || "").truncate(45, omission: ""), (destinataire_responsable || "").truncate(35, omission: ""), poids_en_tonnes.truncate(8, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), 1, nil, (destinataire_responsable || "").truncate(35, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil ]
      csv << ["11", code_operation, CodeDr[code_operation].truncate(35, omission: ""), (destinataire_responsable || "").truncate(60, omission: ""), bordereau_date_transport.strftime("%Y%m%d"), nil]
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
  #def to_ebsdd_avant_h
    #CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      ##binding.pry
      #csv << ["00", ecodds_id, bordereau_id, nil]
      #csv << ["01", 4, producteur.siret, producteur.nom.truncate(5, omission: ''), producteur.adresse, producteur.cp, producteur.ville, producteur.tel, producteur.fax, producteur.email, producteur.responsable, nil]
      #csv << ["02", (entreposage_provisoire ? 1 : 0), destinataire_siret, destinataire_nom, destinataire_adresse, destinataire_cp, destinataire_ville, destinataire_tel, destinataire_fax, destinataire_email, destinataire_responsable, num_cap, "R13", nil]
      #csv << ["03", dechet_denomination, 1, DechetDenomination[dechet_denomination], dechet_consistance, nil ]
      #csv << ["04", DechetNomenclature[dechet_denomination], nil ]
      #csv << ["05", dechet_conditionnement, dechet_nombre_colis, nil ]
      #csv << ["06", type_quantite, poids_en_tonnes, nil ]
      #csv << ["08", collecteur_siret, collecteur_nom, collecteur_adresse, collecteur_cp, collecteur_ville, collecteur_tel, collecteur_fax, collecteur_email, collecteur_responsable, (mode_transport == 1 ? recepisse : nil), (mode_transport == 1 ? collecteur_cp : nil), (mode_transport == 1 ? bordereau_limite_validite.strftime("%Y%m%d") : nil), (mode_transport ? 1 : 0), bordereau_date_transport.strftime("%Y%m%d"), (transport_multimodal ? 1 : 0), nil ]
      #csv << ["09", emetteur_nom, bordereau_date_transport.strftime("%Y%m%d"), nil]
      #csv << ["10", destinataire_siret, destinataire_nom, destinataire_adresse, destinataire_cp, destinataire_ville, destinataire_responsable, poids_en_tonnes, bordereau_date_transport.strftime("%Y%m%d"), 1, nil, destinataire_responsable, bordereau_date_transport.strftime("%Y%m%d"), nil ]
      #csv << ["11", code_operation, CodeDr[code_operation], destinataire_responsable, bordereau_date_transport.strftime("%Y%m%d"), nil]
      #csv << ["12", traitement_prevu, destination_ult_siret, destination_ult_nom, destination_ult_adresse, destination_ult_cp, destination_ult_ville, destination_ult_tel, destination_ult_fax, destination_ult_mel, destination_ult_contact , nil]
      #if entreposage_provisoire
        #csv << ["13", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
        #csv << ["14", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
        #csv << ["15", DechetNomenclature[mention_titre_reglements_ult], nil, nil ]
        #csv << ["16", dechet_conditionnement_ult, dechet_nombre_colis_ult, nil ]
        #csv << ["17", type_quantite_ult, poids_en_tonnes_ult, nil ]
        #csv << ["18", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
        #csv << ["19", nil, nil, nil ]
      #end
      #if transport_multimodal
        #csv << ["20", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
        #csv << ["21", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      #end
    #end
  #end

  def self.has_every_bsd_completed?
    Ebsdd.where(status: :incomplet).exists?
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
        if @document.save
          result = created_from_spreadsheet spreadsheet, attrs
          @document[:failed] = result[:failed]
          @document[:total] = result[:total]
          @document[:exec_time] = result[:exec_time]
          @document[:producteurs] = result[:producteurs]
          binding.pry

          @document.save!
        else
          errors << "Impossible de sauvegarder le document. Veuillez transmettre ce document à votre administrateur pour analyse."
        end
      else
        errors << "Un fichier contenant les mêmes données existe déjà. Veuillez importer un autre fichier."
      end
    end
    [result, errors]
  end

  def self.producteur_attr_indexes attr, headers
    h = headers.reduce( {} ) do | h, _i |
      i = _i.downcase.strip
      attr.each do | a |
        h[a] = headers.index(_i) if a =~ /#{i}/
      end
      h
    end
    h
  end

  def self.created_from_spreadsheet spreadsheet, attrs
    header              = spreadsheet.row(1).map{ |h| h.downcase.strip }
    bordereau_id_column = header.index("bordereau_id")
    producteur_attrs = producteur_attr_indexes(attrs, header)
    failed, start, total, new_producteurs = [], Time.now, 0, []
    unless bordereau_id_column.nil? || producteur_attrs.empty?
      (2..spreadsheet.last_row).each do | i |
        total += 1
        row = spreadsheet.row(i)
        bordereau_id = row[bordereau_id_column]
        producteur_nom = row[producteur_attrs[:producteur_nom]].squish
        producteur = if Producteur.where(nom: producteur_nom).exists?
          Producteur.find_by(nom: producteur_nom)
        else
          new_producteur = producteur_attrs.reduce({}) do  | h, (_k,v) |
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
            ebsdd[cur_header.to_sym] = cur_cell unless producteur_attrs.keys.include?(cur_header.to_sym)
          end
          ebsdd.line_number = i
          ebsdd.status = :import
          ebsdd.productable = producteur
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
  def self.import(file)
    out = { rows: nil, errors: [] }
    spreadsheet = open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.first
    if spreadsheet.last_row > 1
      header    = spreadsheet.row(1).map{ |h| h.downcase.strip }
      checksum  = Digest::MD5.hexdigest(file.read)
      unless Attachment.where(checksum: checksum).exists?
        @document = Attachment.new( { attachment: file, checksum: checksum } )
        #@document.attachment = file
        if @document.save
          rows = []
          bordereau_id_column = header.index("bordereau_id")
          unless bordereau_id_column.nil?
            (2..spreadsheet.last_row).each do | i |
              column = []
              begin
                ebsdd = Ebsdd.find_or_initialize_by({bordereau_id: spreadsheet.cell(i, bordereau_id_column+1) } )
              rescue
                binding.pry
              end
              (1..spreadsheet.last_column).each do | j |
                if header.count > j - 1
                  cur_header = header[ j - 1 ]
                  cur_cell = if spreadsheet.cell(i,j).is_a? Float
                               spreadsheet.cell(i,j).to_i
                             elsif spreadsheet.cell(i,j).is_a? String
                               spreadsheet.cell(i,j).squish
                             else
                               spreadsheet.cell(i,j)
                             end
                end
                ebsdd[cur_header.to_sym] = cur_cell
                column << "#{spreadsheet.cell(i,j)}"
              end
              ebsdd.line_number = i
              ebsdd.status = :import
              ebsdd.save(validate: false)
              @document.ebsdds.push(ebsdd)
              rows << column
            end
          else
            out[:errors] << "Impossible de trouver le numéro de bordereau dans le document. Veuillez transmettre ce document à votre administrateur pour analyse."
          end
        else
          out[:errors] << "Impossible de sauvegarder le document. Veuillez transmettre ce document à votre administrateur pour analyse."
        end
      else
        out[:errors] << "Un fichier contenant les mêmes données existe déjà. Veuillez importer un autre fichier."
      end
    end
    out[:rows] = rows
    out
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.search params
    if params.has_key?(:status)
      Ebsdd.where(status: params[:status].singularize).order_by(created_at: :asc)
    else
      Ebsdd.all
    end
  end

  protected

  def normalize
    self[:recepisse] = nil unless read_attribute(:mode_transport) == 1
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

end
