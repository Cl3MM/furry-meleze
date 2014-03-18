class Prout < Company

  has_many :ebsdds

  #include Mongoid::Document
  #include Mongoid::Timestamps

  ##has_many :ebsdds#, inverse_of: :ebsdds
  ##has_many :producteur, class_name: "Producteur", autosave: true, inverse_of: :producteur
  ##has_many :collecteur, class_name: "Producteur", autosave: true, inverse_of: :collecteur

  #scope :collecteurs, where( is_collecteur: true)
  #scope :producteurs, Producteur.or( { is_collecteur: false}, { :is_collecteur.exists => false } ).asc(:nom)

  #field :siret, type: String
  #field :nom, type: String
  #field :adresse, type: String
  #field :cp, type: String
  #field :ville, type: String
  #field :tel, type: String
  #field :fax, type: String
  #field :email, type: String, default: nil
  #field :responsable, type: String
  #field :actif, type: Boolean
  #field :is_collecteur, type: Boolean

  #field :recepisse, type: String, default: ->{ id }
  #field :mode_transport, type: Integer, default: 1
  #field :limite_validite, type: Date, default: ->{ 10.days.from_now }

  #validates_presence_of :recepisse, :limite_validite, :mode_transport,
    #if: -> { self[:is_collecteur] }

  #attr_accessible :siret, :nom, :adresse, :cp, :ville, :tel, :fax, :email, :responsable, :actif, :is_collecteur, :recepisse, :mode_transport, :limite_validite

  #validates_presence_of :nom, :cp #, :email, :siret, :tel, :fax

  ##validates :siret,  numericality: { only_integer: true }
  #def self.check_headers headers
    #attrs = [
      #:siret, :nom, :adresse, :cp, :ville,
      #:tel, :fax, :email, :responsable, :actif,
    #]
    #h = headers.reduce( {} ) do | h, _i |
      #i = _i.downcase.strip
      #attrs.each do | a |
        #h[a] = headers.index(_i) + 1 if a =~ /#{i}/
      #end
      #h
    #end
    #h.keys.size == attrs.size ? h : nil
  #end
  #def self.import(file)
    #counter = Producteur.count
    #spreadsheet = open_spreadsheet(file)
    #spreadsheet.default_sheet = spreadsheet.sheets.first
    #if spreadsheet.last_row > 1
      #headers = spreadsheet.row(1).map{ |h| h.downcase.strip }
      #unless (headers_hash = check_headers(headers)).nil?
        #(2..spreadsheet.last_row).each do | i |
          #params = headers_hash.reduce({}) do | _h, (k, v) |
          #cell = spreadsheet.cell(i, v)
          #_h[k] = if cell.is_a? Float
                    #cell.to_s
                  #else
                    #(cell.squish).blank? ? nil : cell.squish
                  #end
          #_h
        #end
        #create_from_import(params)
        #end
      #end # unless headers_hash
    #end
    #Producteur.count - counter > 0 ? true : false
  #end
  #def self.create_from_import params
    #unless params[:nom].blank?
      #params[:actif] = (params[:actif].downcase == "o" ? true : false)
      #params[:siret].gsub!(/\s/, "") unless params[:siret].nil?
      #Producteur.create(params)
    #end
  #end
  #def self.open_spreadsheet(file)
    #case File.extname(file.original_filename)
    #when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    #when ".xls" then Roo::Excelx.new(file.path, nil, :ignore)
    #when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    #else raise "Unknown file type: #{file.original_filename}"
    #end
  #end
  #def self.search params
    #if params.has_key?(:status)
      #Producteur.all.order_by(nom: :asc)
    #else
      #Producteur.all.order_by(nom: :asc)
    #end
  #end
end
