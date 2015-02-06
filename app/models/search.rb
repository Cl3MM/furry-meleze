# encoding: utf-8

class Search
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date_min, type: Date
  field :date_max, type: Date
  field :producteur_id, type: String
  field :produit_id, type: String
  field :status, type: Symbol
  field :type, type: Symbol
  field :bordereau_id, type: String
  field :ecodds_id, type: String
  field :poids_min, type: Float
  field :poids_max, type: Float
  field :collecteur_id, type: String
  field :destination_id, type: String
  field :destinataire_id, type: String
  field :bon_de_sortie_id, type: String
  field :bons_de_sortie_inclus, type: Boolean
  field :bons_de_sortie_only, type: Boolean, default: false

  attr_accessible :bordereau_id, :producteur_id, :collecteur_id, :produit_id, :date_min,
    :date_max, :status, :type, :poids_min, :poids_max, :destinataire_id, :status, :type, :ecodds_id,
    :bon_de_sortie_id, :bons_de_sortie_inclus, :bons_de_sortie_only

  validates :status, inclusion: {in: ["nouveau", "en_attente", "attente_sortie", "complet", "clos"]} unless Proc.new {|p| p.status.blank?}
  validates :type, inclusion: {in: ["ecodds", "hors_ecodds", "ddm", "ddi"] } unless Proc.new {|p| p.type.blank?}
  validates :poids_min, numericality: true, greater_than_or_equal_to: 0 unless Proc.new {|p| p.poids_min.blank?}
  validates :poids_max, numericality: true, greater_than_or_equal_to: 0 unless Proc.new {|p| p.poids_max.blank?}

  def bons_de_sortie
    @bds ||= find_bds
  end

  def ebsdds
    @ebsdds ||= find_ebsdds
  end

  def column_names
    [ "Jours", "Mois", "Année", "E/S", "N° de Bordereau", "N° ECODDS", "Nom du client", "Adresse", "Produits", "Transporteur", "Poids", "Date Création" ]
  end
  def ligne_export_matiere_ebsdd ebsdd
    [
      ebsdd.bordereau_date_transport.strftime("%d"),
      ebsdd.bordereau_date_transport.strftime("%m"),
      ebsdd.bordereau_date_transport.strftime("%Y"),
      "E",
      ebsdd.bid,
      (ebsdd.ecodds_id.present? ? ebsdd.ecodds_id : nil),
      (ebsdd.producteur.nom.present? ? ebsdd.producteur.nom : nil),
      (ebsdd.producteur.adresse.present? ? ebsdd.producteur.adresse : nil),
      ebsdd.produit.nom,
      ebsdd.collecteur.nom,
      "#{ebsdd.poids}".gsub(".",","),
      ebsdd.created_at.strftime("%d/%m/%Y"),
      (ebsdd.has_bon_de_sortie? ? ebsdd.bon_de_sortie.id : nil)
    ]
  end
  def ligne_export_matiere_bds bds
    date = bds.date_sortie.nil? ? bds.created_at : bds.date_sortie
    [
      date.strftime("%d"),
      date.strftime("%m"),
      date.strftime("%Y"),
      "S",
      bds.id,
      nil,
      bds.destination.nom, #(bds.type == :ecodds ? "ECODDS" : "Valespace"),
      bds.destination.adresse, #"928 Avenue de la Houille Blanche",
      bds.produit.nom,
      (bds.collecteur ? bds.collecteur.nom : nil), #"Trialp",
      "#{bds.poids}".gsub(".",","),
      bds.created_at.strftime("%d/%m/%Y")
    ]
  end
  def export_gestion_matiere
    CSV.generate({:col_sep => ";"}) do |csv|
      csv << column_names
      @ebsdds.order_by(bordereau_date_transport: 1).each do | ebsdd |
        csv << ligne_export_matiere_ebsdd(ebsdd)
      end if ebsdds.any?
      @bds.order_by(created_at: 1).each do | b |
        csv << ligne_export_matiere_bds(b)
      end if bons_de_sortie.present? && bons_de_sortie.any?
    end
  end

  def criteres
    s = []
    s << "Bons de sortie seulement" if bons_de_sortie_only
    s << "Numéro de bordereau : #{bordereau_id}" if bordereau_id.present?
    s << "Numéro ECODDS : #{ecodds_id}" if ecodds_id.present?
    s << "Numéro de bon de sortie : #{bon_de_sortie_id}" if bon_de_sortie_id.present?
    s << (bons_de_sortie_inclus.present? ? "Bons de sortie Inclus" : "Bons de sortie Exclus") unless bons_de_sortie_only
    s << "Date minimum : #{date_min.strftime("%d/%m/%Y")}" if date_min.present?
    s << "Date maximum : #{date_max.strftime("%d/%m/%Y")}" if date_max.present?
    s << "Poids minimum : #{poids_min.to_i} kg" if poids_min.present?
    s << "Poids maximum : #{poids_max.to_i} kg" if poids_max.present?
    s << "Statut : #{status_pretty}" if status.present?
    s << "Type : #{type_pretty}" if type.present?
    s << "Producteur : #{Producteur.find( producteur_id).try(:nom)}" if producteur_id.present?
    s << "Collecteur : #{Collecteur.find( collecteur_id).try(:nom)}" if collecteur_id.present?
    s << "Destination : #{Destination.find( destination_id).try(:nom)}" if destination_id.present?
    s << "Destinataire : #{Destinataire.find( destinataire_id).try(:nom)}" if destinataire_id.present?
    s << "Déchet : #{Produit.find(produit_id).try(:nom)}" if produit_id.present?
    s
  end


  def status_pretty
    case status
    when :nouveau
      "Nouveau"
    when :en_attente
      "Attente Réception"
    when :attente_sortie
      "En Stock"
    when :clos
      "Archivé"
    when :complet
      "Complet"
    end
  end
  def type_pretty
    case type
    when :ecodds
      "EcoDDS"
    when :hors_ecodds
      "Non EcoDDS"
    when :ddm
      "Déchet Dangereux Ménager"
    when :ddi
      "Déchet Dangereux Industriel"
    end
  end

  private

  def find_bds
    if bons_de_sortie_inclus.present? || bon_de_sortie_id.present? || bons_de_sortie_only
      bds = bon_de_sortie_id.present? ? BonDeSortie.where(id: /#{bon_de_sortie_id}/) : BonDeSortie.all
      bds = bds.gte(created_at: date_min.beginning_of_day) if date_min.present?
      bds = bds.lte(created_at: date_max.end_of_day) if date_max.present?
      bds = bds.gte(poids: poids_min) if poids_min.present?
      bds = bds.lte(poids: poids_max) if poids_max.present?
      bds = bds.where(destination_id: destination_id) if destination_id.present?
      bds = bds.where(produit_id: produit_id) if produit_id.present?
      bds = bds.where(type: :ecodds) if type.present?
    end
    bds || nil
  end
  def find_ebsdds
    return [] if bons_de_sortie_only
    ebsdds = bordereau_id.present? ? Ebsdd.where(bid: /#{bordereau_id}/) : Ebsdd.all.exists(archived: false)
    ebsdds = ebsdds.where(ecodds_id_str: /#{ecodds_id}/) if ecodds_id.present?
    ebsdds = ebsdds.gte(bordereau_date_transport: date_min.beginning_of_day) if date_min.present?
    ebsdds = ebsdds.lte(bordereau_date_transport: date_max.end_of_day) if date_max.present?
    ebsdds = ebsdds.gte(bordereau_poids: poids_min) if poids_min.present?
    ebsdds = ebsdds.lte(bordereau_poids: poids_max) if poids_max.present?
    ebsdds = ebsdds.where(producteur_id: producteur_id) if producteur_id.present?
    ebsdds = ebsdds.where(collecteur_id: collecteur_id) if collecteur_id.present?
    ebsdds = ebsdds.where(destination_id: destination_id) if destination_id.present?
    ebsdds = ebsdds.where(produit_id: produit_id) if produit_id.present?
    ebsdds = ebsdds.where(destinataire_id: destinataire_id) if destinataire_id.present?
    ebsdds = ebsdds.where(status: status) if status.present?
    if type.present? && !ecodds_id.present?
      if [:ecodds, :hors_ecodds].include?(type)
        ebsdds = if type == :ecodds
                   ebsdds.where(:ecodds_id.nin => ["", nil])
                 else
                   ebsdds = ebsdds.where(:ecodds_id.in => ["", nil])
                 end
      else
        pids = case type
               when :ddm
                 Produit.where(is_ddm: 1).map(&:id)
               when :ddi
                 Produit.where(is_ddi: 1).map(&:id)
               end
        ebsdds = ebsdds.in(produit_id: pids)
      end
    end
    ebsdds
  end
end
