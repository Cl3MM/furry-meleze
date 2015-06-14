# encoding: utf-8

module Statisticable
  extend ActiveSupport::Concern

  included do
    def self.seuils
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

      #mr = Ebsdd.where(:status.in => [:attente_sortie, :clos]).map_reduce(map, reduce).out(inline: true)
      mr = Ebsdd.where(status: :attente_sortie).map_reduce(map, reduce).out(inline: true)
      produits = {}
      mr.entries.reduce([]) do |a, e|
        if produits.keys.include? e["_id"]
          produit = produits[e["_id"]]
        else
          produit = Produit.find e["_id"]
          produits[e["_id"]] = produit
        end
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
      }.squish

      reduce = %Q{
      function(id, poids) {
        return Array.sum(poids);
      };
      }.squish
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

    def self.quantites_to_csv min = Date.today.beginning_of_month.beginning_of_day, max = Date.today.end_of_month.end_of_day
      min, max = max, min if min > max
      min = min.beginning_of_day
      max = max.end_of_day
      map = %Q{
      function() {
        emit( this.nom_produit, this.bordereau_poids );
      };
      }.squish

      reduce = %Q{
      function(nom, poids) {
        return Array.sum(poids);
      };
      }.squish

      ecodds  = Ebsdd.in(status: [:attente_sortie, :clos]).between(bordereau_date_transport: min..max).and(is_ecodds: true).map_reduce(map, reduce).out(inline: true).entries
      necodds = Ebsdd.in(status: [:attente_sortie, :clos]).between(bordereau_date_transport: min..max).and(is_ecodds: false).map_reduce(map, reduce).out(inline: true).entries

      content = necodds.reduce([]) do | ar, e |
        eco = ecodds.find{ |o| o["_id"] == e["_id"]  }.try(:[], "value") || 0
        ecodds.delete_if { |o| o["_id"] == e["_id"] } if eco > 0
        ar << { nom: e["_id"], hors_ecodds: e["value"], ecodds: eco }
        ar
      end
      content += ecodds.reduce([]) do | ar, e |
        ar << { nom: e["_id"], hors_ecodds: 0, ecodds: e["value"]}
        ar
      end
      content.sort_by! do | h |
        h[:nom]
      end

      CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
        #csv << ["Nom du déchet", "code dr", Poids (kg)", "EcoDDS", "DDM", "DDI"]
        #data.each do | qte |
        #csv << [qte[:nom], qte[:codedr], qte[:poids], qte[:ecodds], qte[:ddm], qte[:ddi]]
        #end
        csv << ["Nom du déchet","Non EcoDDS (kg)", "EcoDDS (kg)", "code dr"]
        content.each do | item |
          csv << [item[:nom], item[:hors_ecodds], item[:ecodds], item[:code_dr]]
        end
      end
    end

    def self.quantites_en_stock min = Date.today.beginning_of_week.beginning_of_day, max = Date.today.end_of_week.end_of_day
      min, max = max, min if min > max
      min = min.beginning_of_day
      max = max.end_of_day
      eco = hors_eco = quantites_en_stock_map_reduce min, max
      format_map_reduce_results eco, hors_eco
    end
    def self.quantites_en_stock_map_reduce min, max
      map = %Q{
      function() {
        emit( this.nom_produit, this.bordereau_poids );
      };
      }.squish

      reduce = %Q{
      function(nom, poids) {
        return Array.sum(poids);
      };
      }.squish

      ecodds  = Ebsdd.where(:status.in => [:attente_sortie, :clos]).between(bordereau_date_transport: min..max).and(is_ecodds: true).map_reduce(map, reduce).out(inline: true).entries
      necodds = Ebsdd.where(:status.in => [:attente_sortie, :clos]).between(bordereau_date_transport: min..max).and(is_ecodds: false).map_reduce(map, reduce).out(inline: true).entries
      [ecodds, necodds]
    end
    def self.format_map_reduce_results ecodds, necodds
      produits = {}
      content = necodds.reduce([]) do | ar, e |
        code_dr = if produits.keys.include? e["_id"]
                    produits[e["_id"]]
                  else
                    produit = Produit.find_by(nom: e["_id"])
                    produits[e["_id"]] = produit.code_rubrique
                  end
        eco = ecodds.find{ |o| o["_id"] == e["_id"]  }.try(:[], "value") || 0
        ecodds.delete_if { |o| o["_id"] == e["_id"] } if eco > 0
        ar << { nom: e["_id"], hors_ecodds: e["value"], ecodds: eco, code_dr: code_dr }
        ar
      end
      content += ecodds.reduce([]) do | ar, e |
        code_dr = if produits.keys.include? e["_id"]
                    produits[e["_id"]]
                  else
                    produit = Produit.find_by(nom: e["_id"])
                    produits[e["_id"]] = produit.code_rubrique
                  end
        ar << { nom: e["_id"], hors_ecodds: 0, ecodds: e["value"], code_dr: code_dr}
        ar
      end
      content.sort_by! do | h |
        h[:nom]
      end
    end

    def self.quantites_en_stock_csv min = Date.today.beginning_of_week.beginning_of_day, max = Date.today.end_of_week.end_of_day
      eco, hors_eco = quantites_en_stock min, max
      content = format_map_reduce_results eco, hors_eco
      generate_csv_file( { data: content, headers: ["Nom du déchet","Non EcoDDS (kg)", "EcoDDS (kg)", "Code DR"] })
    end

    def self.quantites_sorties_csv min = Date.today.beginning_of_week.beginning_of_day, max = Date.today.end_of_week.end_of_day
      content = quantites_sorties min, max
      generate_csv_file( { data: content, headers: ["Nom du déchet","Non EcoDDS (kg)", "EcoDDS (kg)", "Code DR"] })
    end

    def self.generate_csv_file data
      CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do | csv |
        headers = data[:data].first.keys.map { |k| k.to_s.humanize }
        csv << data[:headers] || headers
        data[:data].each do | item |
          csv << [item[:nom], item[:hors_ecodds], item[:ecodds]]
        end
      end
    end

    def self.quantites_sorties min = Date.today.beginning_of_week.beginning_of_day, max = Date.today.end_of_week.end_of_day
      min, max = max, min if min > max
      min = min.beginning_of_day
      max = max.end_of_day
      eco, hors_eco = quantites_sorties_map_reduce min, max
      format_map_reduce_results eco, hors_eco
    end

    def self.quantites_sorties_map_reduce min, max
      map = %Q{
      function() {
        emit( this.nom_produit, this.bordereau_poids );
      };
      }.squish

      reduce = %Q{
      function(nom, poids) {
        return Array.sum(poids);
      };
      }.squish

      ecodds  = Ebsdd.where(status: :clos).between(closed_on: min..max).and(is_ecodds: true).map_reduce(map, reduce).out(inline: true).entries
      necodds = Ebsdd.where(status: :clos).between(closed_on: min..max).and(is_ecodds: false).map_reduce(map, reduce).out(inline: true).entries
      [ecodds, necodds]
    end

    def self.camions_to_csv date_min, date_max
      CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
        csv << ["Nom du déchet", "Poids (kg)"]
        camions(date_min, date_max)[:data].each do | qte |
          csv << [qte[:nom], qte[:poids]]
        end
      end
    end
    def self.add_closed_on
      bons = {}
      Ebsdd.where( :bon_de_sortie_id.exists => true).each do | e |
        if bons.keys.include? e.bon_de_sortie_id
          e.update_attribute(:closed_on, bons[e.bon_de_sortie_id])
        else
          bon = BonDeSortie.find_by(id: e.bon_de_sortie_id)
          bons[e.bon_de_sortie_id] = bon.date_sortie || bon.created_at
          e.update_attribute(:closed_on, bons[e.bon_de_sortie_id])
        end
      end
    end

  end
end
