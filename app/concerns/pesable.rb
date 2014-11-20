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
    pesees.map(&:poids_calcule).reduce(:+)
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
end
