class Destination
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds
  attr_accessible :siret, :nom, :adresse, :cp, :ville, :tel, :fax, :email, :responsable, :actif, :recepisse,
    :mode_transport, :limite_validite, :nomenclatures

  field :nomenclatures, type: Array
  field :siret, type: String
  field :nom, type: String
  field :adresse, type: String
  field :cp, type: String
  field :ville, type: String
  field :tel, type: String
  field :fax, type: String
  field :email, type: String, default: nil
  field :responsable, type: String

  #validates_presence_of :recepisse,# :bordereau_limite_validite,
    #if: -> { self[:mode_transport] == 1 }

  #n = %w(200114 200115 160904 200119 160504 200113)
  #Destination.create(nom: "SARPI", adresse: "461 Rue George Sand", ville: "Talaudière (La)", cp: "42350", tel: "04 77 47 50 68", responsable: "M. FELICIANO pascal", siret: "485-234-838-00018", email: "pfeliciano@sarpindustries.fr", fax: "04 77 47 53 50", nomenclatures: n)
  #Destination.create(nom: "TREDI", adresse: "519 Rue Denis Papin", ville: "Salaise-sur-Sanne", cp: "38150", tel: "04 74 86 58 11", responsable: "M. ANDRES", siret: "338-185-762-00071", 
                    #email: "m.andres@tredi.groupe-seche.com", fax: "04 74 86 16 97", nomenclatures: ["200127", "150110"])
  #Destination.create(nom: "CHIMIREC", adresse: "9 zac les toupes", ville: "Montmorot", cp: "39570", tel: "03 84 87 05 20", responsable: "M. JANVIER Christian", siret: "393-903-067-00014", 
                    #email: "chimirec-centrest@chimirec.fr", fax: "03 84 24 81 64", nomenclatures: ["160107"])

end
