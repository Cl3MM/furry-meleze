# encoding: utf-8

class Ebsdd # < ActiveRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.per_page
    15
  end

  belongs_to :attachment #, :inverse_of => :ebsdds
  attr_accessible :id, :_id

  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}#{"%04d" % Ebsdd.count}" }
  field :status, type: String, default: "incomplet"
  field :line_number, type: Integer
  field :bordereau_id, type: Integer
  field :bordereau_poids, type: Float
  field :producteur_nom, type: String
  field :producteur_adresse, type: String
  field :producteur_cp, type: String
  field :producteur_ville, type: String
  field :producteur_tel, type: String
  field :producteur_fax, type: String
  field :producteur_responsable, type: String
  field :destinataire_siret, type: String
  field :destinataire_nom, type: String
  field :destinataire_adresse, type: String
  field :destinataire_cp, type: String
  field :destinataire_ville, type: String
  field :destinataire_tel, type: String
  field :destinataire_fax, type: String
  field :destinataire_responsable, type: String
  field :nomenclature_dechet_code_nomen_c, type: Integer
  field :nomenclature_dechet_code_nomen_a, type: Integer
  field :collecteur_siret, type: String
  field :collecteur_nom, type: String
  field :collecteur_adresse, type: String
  field :collecteur_cp, type: String
  field :collecteur_ville, type: String
  field :collecteur_tel, type: String
  field :collecteur_fax, type: String
  field :collecteur_responsable, type: String
  field :bordereau_date_transport, type: Date
  field :bordereau_poids, type: Integer
  field :libelle, type: String
  field :bordereau_date_creation, type: Date
  field :num_cap, type: String
  field :dechet_denomination, type: Integer
  field :dechet_consistance, type: Integer
  field :dechet_nomenclature, type: String
  field :dechet_conditionnement, type: String
  field :dechet_nombre_colis, type: Integer
  field :type_quantite, type: String
  field :emetteur_nom, type: String

  attr_accessible :bordereau_id, :producteur_nom, :producteur_adresse, :producteur_cp, :producteur_ville,
    :producteur_tel, :producteur_fax, :producteur_responsable, :destinataire_siret, :destinataire_nom,
    :destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_tel, :destinataire_fax,
    :destinataire_responsable, :nomenclature_dechet_code_nomen_c, :nomenclature_dechet_code_nomen_a,
    :collecteur_siret, :collecteur_nom, :collecteur_adresse, :collecteur_cp, :collecteur_ville, :libelle,
    :collecteur_tel, :collecteur_fax, :collecteur_responsable, :bordereau_date_transport, :bordereau_poids,
    :bordereau_date_creation, :num_cap, :dechet_denomination, :dechet_consistance, :dechet_nomenclature,
    :dechet_conditionnement, :dechet_nombre_colis, :type_quantite, :bordereau_poids, :emetteur_nom

  def poids_en_tonnes
    "#{"%08.3f" % (read_attribute(:bordereau_poids) / 1000.0) }"
  end
  def is_incomplete?
    status == "incomplet"
  end
  def bid
    bid = read_attribute(:bordereau_id)
    unless bid.nil? 
      "%.0f" % bid
    else
      "#"
    end
  end
  def short_bid
    bid.gsub('1000000', "")
  end

  def nommenclature_dechet_code_nomen_c_a
    "#{nomenclature_dechet_code_nomen_c}#{nomenclature_dechet_code_nomen_a}"
  end
  def to_csv
    CSV.generate({:col_sep => ";"}) do |csv|
      column_names = attributes.keys
      csv << column_names
      csv << attributes.values_at(*column_names)
    end
  end
  def to_ebsdd
    CSV.generate({:col_sep => ";"}) do |csv|
      #binding.pry
      csv << ["00", nil, bordereau_id, nil]
      csv << ["01", 4, 'producteur_id', producteur_nom, producteur_adresse, producteur_cp, producteur_ville, producteur_tel, producteur_fax, 'producteur_email', producteur_responsable, nil]
      csv << ["02", 0, destinataire_siret, destinataire_nom, destinataire_adresse, destinataire_cp, destinataire_ville, destinataire_tel, destinataire_fax, 'destinataire_email', destinataire_responsable, 'CAP#', 'R13', nil]
      csv << ["03", nommenclature_dechet_code_nomen_c_a, 1, 'Dénomination usuelle', 'Consistance', nil ]
      csv << ["04", "Mention au titre des règlements", nil ]
      csv << ["05", "AUTRE", "Nombre de colis", nil ]
      csv << ["06", "E", "Volume en tonne", nil ]
      csv << ["07", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["08", collecteur_siret, collecteur_nom, collecteur_adresse, collecteur_cp, collecteur_ville, collecteur_tel, collecteur_fax, collecteur_cp[0..2], collecteur_responsable, nil, nil, bordereau_date_transport.strftime("%Y%m%d"), nil ]
      csv << ["09", "Nom", bordereau_date_transport.strftime("%Y%m%d")]
      csv << ["10", destinataire_siret, destinataire_nom, destinataire_adresse, destinataire_cp, destinataire_ville, destinataire_responsable, poids_en_tonnes, bordereau_date_transport.strftime("%Y%m%d"), 0, nil, destinataire_responsable, bordereau_date_transport.strftime("%Y%m%d") ]
      csv << ["11", "Code DR", "Description", destinataire_responsable, bordereau_date_transport.strftime("%Y%m%d")]
      csv << ["12", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["13", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["14", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["15", nil, nil ]
      csv << ["16", nil, nil ]
      csv << ["17", nil, nil, nil ]
      csv << ["18", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["19", nil, nil, nil ]
      csv << ["20", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["21", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
    end
  end

  def to_ebsdd_template
    CSV.generate({:col_sep => ";"}) do |csv|
      #binding.pry
      csv << ["00", nil, :bordereau_id, nil]
      csv << ["01", 4, 'producteur_id', :producteur_nom, :producteur_adresse, :producteur_cp, :producteur_ville, :producteur_tel, :producteur_fax, 'producteur_email', producteur_responsable, nil]
      csv << ["02", 0, :destinataire_siret, :destinataire_nom, :destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_tel, :destinataire_fax, ':destinataire_email', :destinataire_responsable, 'CAP#', 'R13', nil]
      csv << ["03", :nommenclature_dechet_code_nomen_c_a, 1, 'Dénomination usuelle', 'Consistance', nil ]
      csv << ["04", "Mention au titre des règlements", nil ]
      csv << ["05", "AUTRE", "Nombre de colis", nil ]
      csv << ["06", "E", "Volume en tonne", nil ]
      csv << ["07", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["08", :colllecteur_siret, :colllecteur_nom, :colllecteur_adresse, :colllecteur_cp, :colllecteur_ville, :colllecteur_tel, :colllecteur_fax, :colllecteur_cp[0..2], :colllecteur_responsable, nil, nil, :bordereau_date_transport, nil ]
      csv << ["09", "Nom", :bordereau_date_transport]
      csv << ["10", :destinataire_siret, :destinataire_nom, :destinataire_adresse, :destinataire_cp, :destinataire_ville, :destinataire_responsable, :poids_en_tonnes, :bordereau_date_transport, 0, nil, :destinataire_responsable, :bordereau_date_transport ]
      csv << ["11", "Code DR", "Description", :destinataire_responsable, :bordereau_date_transport]
      csv << ["12", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["13", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["14", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["15", nil, nil ]
      csv << ["16", nil, nil ]
      csv << ["17", nil, nil, nil ]
      csv << ["18", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["19", nil, nil, nil ]
      csv << ["20", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      csv << ["21", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ]
    end
  end

  def self.has_every_bsd_completed?
    Ebsdd.where(status: "incomplet").exists?
  end
  def self.import(file)
    out = { rows: nil, errors: [] }
    spreadsheet = open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.first
    if spreadsheet.last_row > 1
      header    = spreadsheet.row(1).map{ |h| h.downcase.strip }
      checksum  = Digest::MD5.hexdigest(file.read)
      unless Attachment.where(checksum: checksum).exists?
        @document = Attachment.new( { attachment: file, checksum: checksum } )
        #@document.attachment = file
        if @document.save
          rows = []
          bordereau_id_column = header.index("bordereau_id")
          unless bordereau_id_column.nil?
            (2..spreadsheet.last_row).each do | i |
              column = []
              begin
                ebsdd = Ebsdd.find_or_initialize_by({bordereau_id: spreadsheet.cell(i, bordereau_id_column+1) } )
              rescue
                binding.pry
              end
              (1..spreadsheet.last_column).each do | j |
                if header.count > j - 1
                  cur_header = header[ j - 1 ]
                  cur_cell = if spreadsheet.cell(i,j).is_a? Float
                               spreadsheet.cell(i,j).to_i
                             else
                               spreadsheet.cell(i,j)
                             end
                end
                ebsdd[cur_header.to_sym] = cur_cell
                column << "#{spreadsheet.cell(i,j)}"
              end
              ebsdd.line_number = i
              ebsdd.save
              @document.ebsdds.push(ebsdd)
              rows << column
            end
          else
            out[:errors] << "Impossible de trouver le numéro de bordereau dans le document. Veuillez transmettre ce document à votre administrateur pour analyse."
          end
        else
          out[:errors] << "Impossible de sauvegarder le document. Veuillez transmettre ce document à votre administrateur pour analyse."
        end
      else
        out[:errors] << "Un fichier contenant les mêmes données existe déjà. Veuillez importer un autre fichier."
      end
    end
    out[:rows] = rows
    out
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  protected
  def set_status
  end
end
