# encoding: utf-8
class BonDeSortie
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds, autosave: true
  belongs_to :produit, autosave: true

  belongs_to :destination
  #attr_accessible :id, :_id
  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}BDS#{"%04d" % BonDeSortie.count}" }
  field :poids, type: Float
  field :codedr_cadre2, type: String
  field :codedr_cadre12, type: String

  attr_accessible :poids, :codedr_cadre12, :codedr_cadre2

  def self.destinations dest_id, date_min = Date.today.beginning_of_month, date_max = Date.today.end_of_month

    date_min, date_max = date_max, date_min if date_min > date_max
    map = %Q{
      function() {
        var key = new Date(this.created_at.getFullYear(),
                                 this.created_at.getMonth(),
                                 this.created_at.getDate(),
                                 0, 0, 0);
        emit( key, this.poids );
      };
    }

    reduce = %Q{
      function(date, poids) {
        return Array.sum(poids);
      };
    }

    mr = BonDeSortie.where(destination_id: dest_id).between(created_at: date_min..date_max).map_reduce(map, reduce).out(inline: true)
    data = mr.entries.reduce([]) do | a, e |
      a << { jour: e["_id"], poids: e["value"], jourStr: e["_id"].strftime("%d/%m/%Y") }
      a
    end.sort_by { | h | h[:jour] }

    total = BonDeSortie.where(destination_id: dest_id).between(created_at: date_min..date_max).sum(&:poids)
    { 
      data: data,
      destination: Destination.find(dest_id).nom,
      poids_total: total, 
      du: date_min.strftime("%d/%m/%Y"), 
      au: date_max.strftime("%d/%m/%Y") }
  end


end
