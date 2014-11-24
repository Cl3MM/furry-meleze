# encoding: utf-8

module Pesable
  extend ActiveSupport::Concern
  included do
    #embeds_many :pesees #, inverse_of: :ebsdd
    embeds_many :pesees, class_name: "Pesee", inverse_of: :ebsdd
  end

  def poids_pretty
    p = 0.0
    if pesees.any?
      p = pesee_totale
    else
      if bordereau_poids.blank?
        return "-"
      else
        p = bordereau_poids
      end
    end
    pp = "#{"%0.2f" % p}"
    "#{pp.gsub('.',',')} kg"
  end
  def poids
    if pesees.any?
      pesee_totale
    else
      if bordereau_poids.blank?
        0
      else
        bordereau_poids
      end
    end
  end
  def pesee_totale
    poids_brut - poids_tare
  end
  def poids_brut
    pesees.map(&:brut).reduce(:+)
  end
  def poids_tare
    pesees.map(&:poids_tare).reduce(:+)
  end
  def poids_en_tonnes2 attr
    unless attr.nil?
      "#{"%08.3f" % (attr.to_f / 1000.0) }"
    else
      ""
    end
  end
  def poids_en_tonnes_pdf
    "#{"%0.3f" % (poids / 1000.0) }"
  end
  def poids_en_tonnes
    "#{"%08.3f" % (poids / 1000.0) }"
  end
  def poids_en_tonnes_ult
    "#{"%08.3f" % (read_attribute(:bordereau_poids_ult) / 1000.0) }" unless bordereau_poids_ult.nil?
  end
  def pesees_to_pdf
    head = [["Date Création", "#DSD", "Poids Brut", "Poids Tare", "Poids Net", "Désignation Tare" ]]
    data = pesees.map do | p |
      p_brut = "#{"%0.2f kg" % p.brut}".gsub('.',',')
      p_tare = "#{"%0.2f kg" % p.poids_tare}".gsub('.',',')
      p_net  = "#{"%0.2f kg" % (p.brut - p.poids_tare)}".gsub('.',',')
      p_date_creation = p.created_at.strftime("%d/%m/%Y %H:%M")
      [p_date_creation, p.dsd, p_brut, p_tare, p_net, p.nom_tare]
    end
    p_brut_kg = "#{"%0.2f kg" % poids_brut}".gsub('.',',')
    p_tare_kg = "#{"%0.2f kg" % poids_tare}".gsub('.',',')
    p_net_kg = "#{"%0.2f kg" % pesee_totale}".gsub('.',',')
    foot = [["", "Total", p_brut_kg, p_tare_kg, p_net_kg, ""]]

    head + data + foot
  end
end
