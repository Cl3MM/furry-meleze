# encoding: utf-8
class BonDeSortie
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds, autosave: true
  belongs_to :produit, autosave: true

  belongs_to :destination
  #attr_accessible :id, :_id

    # default: ->{ "#{Time.now.strftime("%y%m%d")}BDS#{"%04d" % (BonDeSortie.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count + 1)}" }
  field :_id, type: String, default: -> do
    counter = 1
    now = Time.now.strftime("%Y%m%d")
    start = Date.today.beginning_of_day
    fin = Date.today.end_of_day
    tmp = ""
    loop do
      tmp = "#{now}BDS#{"%04d" % (BonDeSortie.between(created_at: start..fin).count + counter)}"
      counter += 1
      break unless Ebsdd.where(id: tmp).exists?
    end
    tmp
  end

  field :poids, type: Float
  field :codedr_cadre2, type: String
  field :codedr_cadre12, type: String
  field :type, type: Symbol
  field :date_sortie, type: Date
  field :transporteur, type: String

  attr_accessible :poids, :codedr_cadre12, :codedr_cadre2, :type, :date_sortie, :transporteur

  def self.destinations dest_id, date_min = Date.today.beginning_of_month.beginning_of_day, date_max = Date.today.end_of_month.end_of_day
    date_min, date_max = date_max, date_min if date_min > date_max
    date_min = date_min.beginning_of_day
    date_max = date_max.end_of_day

        #var key = new Date(this.created_at.getFullYear(),
                                 #this.created_at.getMonth() + 1,
                                 #this.created_at.getDate(),
                                 #0, 0, 0);
    map = %Q{

      function() {
        var day, month, year;
        year = this.created_at.getFullYear();
        month = (1 + this.created_at.getMonth()).toString();
        month = month.length > 1 ? month : '0' + month;
        day = this.created_at.getDate().toString();
        day = day.length > 1 ? day : '0' + day;
        var key = day + '/' + month + '/' + year;

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
      a << { jour: e["_id"], poids: e["value"], jourStr: e["_id"] }
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
  def self.destinations_to_csv dest_id, date_min, date_max
    CSV.generate( { col_sep: ";", encoding: "ISO8859-15" }) do |csv|
      csv << ["Jour", "Poids (tonnes)"]
      destinations(dest_id, date_min, date_max)[:data].each do | qte |
        csv << [qte[:jourStr], qte[:poids]]
      end
    end
  end
  def set_type
    if ebsdds.any?
      e = ebsdds.first
      self[:type] = e.is_ecodds ? :ecodds : :normal
    end
  end
end
