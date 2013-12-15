class Producteur
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds#, inverse_of: :ebsdds

  field :siret, type: String
  field :nom, type: String
  field :adresse, type: String
  field :cp, type: String
  field :ville, type: String
  field :tel, type: String
  field :fax, type: String
  field :email, type: String, default: nil
  field :responsable, type: String
  field :actif, type: Boolean

  attr_accessible :siret, :nom, :adresse, :cp, :ville, :tel, :fax, :email, :responsable, :actif
  before_create :normalize
  def normalize
    
  end
  validates_presence_of :nom
  #validates :siret,  numericality: { only_integer: true }
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
          _h[k] = (c = spreadsheet.cell(i, v).squish).blank? ? nil : c
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
