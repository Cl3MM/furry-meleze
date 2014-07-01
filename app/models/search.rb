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

  attr_accessible :bordereau_id, :producteur_id, :collecteur_id, :produit_id, :date_min,
    :date_max, :status, :type, :poids_min, :poids_max, :destinataire_id, :status, :type, :ecodds_id,
    :bon_de_sortie_id, :bons_de_sortie_inclus

  validates :status, inclusion: {in: ["nouveau", "en_attente", "attente_sortie", "complet", "clos"]} unless Proc.new {|p| p.status.blank?}
  validates :type, inclusion: {in: ["ecodds", "ddm", "ddi"] } unless Proc.new {|p| p.type.blank?}
  validates :poids_min, numericality: true, greater_than_or_equal_to: 0 unless Proc.new {|p| p.poids_min.blank?}
  validates :poids_max, numericality: true, greater_than_or_equal_to: 0 unless Proc.new {|p| p.poids_max.blank?}

  def bons_de_sortie
    @bds ||= find_bds
  end

  def ebsdds
    @ebsdds ||= find_ebsdds
  end

  def column_names
    [ "Jours", "Mois", "Année", "E/S", "N° de Bordereau", "N° ECODDS", "Nom du client", "Adresse", "Produits", "Transporteur", "Poids" ]
  end
  def ligne_export_matiere_ebsdd ebsdd
    [
      ebsdd.bordereau_date_transport.strftime("%d"),
      ebsdd.bordereau_date_transport.strftime("%m"),
      ebsdd.bordereau_date_transport.strftime("%Y"),
      "E",
      ebsdd.bid,
      (ebsdd.is_ecodds ? ebsdd.ecodds_id : nil),
      (ebsdd.producteur.nom.present? ? ebsdd.producteur.nom : nil),
      (ebsdd.producteur.adresse.present? ? ebsdd.producteur.adresse : nil),
      ebsdd.produit.nom,
      ebsdd.collecteur.nom,
      (ebsdd.bordereau_poids.present? ? ebsdd.bordereau_poids : nil),
    ]
  end
  def ligne_export_matiere_bds bds
    [
      bds.created_at.strftime("%d"),
      bds.created_at.strftime("%m"),
      bds.created_at.strftime("%Y"),
      "S",
      bds.id,
      nil,
      (bds.type == :ecodds ? "ECODDS" : "Valespace"),
      "928 Avenue de la Houille Blanche",
      bds.produit.nom,
      "Trialp",
      bds.poids,
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
    s << "Numéro de bordereau : #{bordereau_id}" if bordereau_id.present?
    s << "Numéro ECODDS : #{ecodds_id}" if ecodds_id.present?
    s << "Numéro de bon de sortie : #{bon_de_sortie_id}" if bon_de_sortie_id.present?
    s << (bons_de_sortie_inclus.present? ? "Bons de sortie Inclus" : "Bons de sortie Exclus")
    s << "date minimum : #{date_min.strftime("%d/%m/%Y")}" if date_min.present?
    s << "date maximum : #{date_max.strftime("%d/%m/%Y")}" if date_max.present?
    s << "poids minimum : #{poids_min.to_i} kg" if poids_min.present?
    s << "poids maximum : #{poids_max.to_i} kg" if poids_max.present?
    s << "statut : #{status_pretty}" if status.present?
    s << "type : #{type_pretty}" if type.present?
    s << "producteur : #{Producteur.find( producteur_id).nom}" if producteur_id.present?
    s << "collecteur : #{Collecteur.find( collecteur_id).nom}" if collecteur_id.present?
    s << "destination : #{Destination.find( destination_id).nom}" if destination_id.present?
    s << "destinataire : #{Destinataire.find( destinataire_id).nom}" if destinataire_id.present?
    s << "déchet : #{Produit.find(produit_id).try(:nom)}" if produit_id.present?
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
    when :ddm
      "Déchet Dangereux Ménager"
    when :ddi
      "Déchet Dangereux Industriel"
    end
  end

  private

  def find_bds
    if bons_de_sortie_inclus.present? || bon_de_sortie_id.present?
      bds = bon_de_sortie_id.present? ? BonDeSortie.where(id: /#{bon_de_sortie_id}/) : BonDeSortie.all
      bds = bds.gte(created_at: date_min) if date_min.present?
      bds = bds.lte(created_at: date_max) if date_max.present?
      bds = bds.gte(poids: poids_min) if poids_min.present?
      bds = bds.lte(poids: poids_max) if poids_max.present?
      bds = bds.where(destination_id: destination_id) if destination_id.present?
      bds = bds.where(produit_id: produit_id) if produit_id.present?
      bds = bds.where(type: :ecodds) if type.present?
    end
    bds || nil
  end
  def find_ebsdds
    ebsdds = bordereau_id.present? ? Ebsdd.where(bid: /#{bordereau_id}/) : Ebsdd.exists(archived: false)
    ebsdds = ebsdds.where(ecodds_id: /#{ecodds_id}/) if ecodds_id.present?
    ebsdds = ebsdds.gte(created_at: date_min) if date_min.present?
    ebsdds = ebsdds.lte(created_at: date_max) if date_max.present?
    ebsdds = ebsdds.gte(bordereau_poids: poids_min) if poids_min.present?
    ebsdds = ebsdds.lte(bordereau_poids: poids_max) if poids_max.present?
    ebsdds = ebsdds.where(producteur_id: producteur_id) if producteur_id.present?
    ebsdds = ebsdds.where(collecteur_id: collecteur_id) if collecteur_id.present?
    ebsdds = ebsdds.where(destination_id: destination_id) if destination_id.present?
    ebsdds = ebsdds.where(produit_id: produit_id) if produit_id.present?
    ebsdds = ebsdds.where(destinataire_id: destinataire_id) if destinataire_id.present?
    ebsdds = ebsdds.where(status: status) if status.present?

    if type.present?
      pids = case type
              when :ecodds
                Produit.where(is_ecodds: 1).map(&:id)
              when :ddm
                Produit.where(is_ddm: 1).map(&:id)
              when :ddi
                Produit.where(is_ddi: 1).map(&:id)
              end
      ebsdds = ebsdds.in(produit_id: pids)
    end
    ebsdds
  end
end
