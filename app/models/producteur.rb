class Producteur < Company

  has_many :ebsdds, inverse_of: :producteur

  def monthly_stats_by_type datemin = Date.today.beginning_of_month, datemax = Date.today.end_of_month
    datemin, datemax = datemax, datemin if datemin > datemax
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
    results = ebsdds.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).and(status: :complet).map_reduce(map, reduce).out(inline: true)
    #results.entries.map{ |i| [DechetDenomination[i["_id"]][3..-1], i["value"].to_i ] }
  end
  def donut_stats
    monthly_stats_by_type.entries.map{ |i| { label: DechetDenomination[i["_id"]][3..-1], value: i["value"].to_i } }.to_json
  end
  def bar_stats
    monthly_stats_by_type.entries.map{ |i| { y: DechetDenomination[i["_id"]][3..-1], x: i["value"].to_i } }.to_json
  end
  def self.check_headers headers
    attrs = [
      :siret, :nom, :adresse, :cp, :ville,
      :tel, :fax, :email, :responsable, :actif,
    ]
    h = headers.reduce( {} ) do | h, _i |
      i = _i.downcase.strip
      attrs.each do | a |
        h[a] = headers.index(_i) + 1 if a =~ /#{i}/
      end
      h
    end
    h.keys.size == attrs.size ? h : nil
  end
  def self.import(file)
    counter = Producteur.count
    spreadsheet = open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.first
    if spreadsheet.last_row > 1
      headers = spreadsheet.row(1).map{ |h| h.downcase.strip }
      unless (headers_hash = check_headers(headers)).nil?
        (2..spreadsheet.last_row).each do | i |
          params = headers_hash.reduce({}) do | _h, (k, v) |
          cell = spreadsheet.cell(i, v)
          _h[k] = if cell.is_a? Float
                    cell.to_s
                  else
                    (cell.squish).blank? ? nil : cell.squish
                  end
          _h
        end
        create_from_import(params)
        end
      end # unless headers_hash
    end
    Producteur.count - counter > 0 ? true : false
  end
  def self.create_from_import params
    unless params[:nom].blank?
      params[:actif] = (params[:actif].downcase == "o" ? true : false)
      params[:siret].gsub!(/\s/, "") unless params[:siret].nil?
      Producteur.create(params)
    end
  end
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excelx.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  def self.search params
    if params.has_key?(:status)
      Producteur.all.order_by(nom: :asc)
    else
      Producteur.all.order_by(nom: :asc)
    end
  end
end
