class Immatriculation
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :normalize

  field :valeur, type: String
  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}#{"%04d" % Immatriculation.count}" }

  def self.to_select
    Immatriculation.all.asc(:valeur).map{ |i| [i.valeur, i.id] }
  end

  def normalize
    #self[:valeur] = self[:valeur].strip.upcase#.gsub(/(\s|[&~"#'\(-\\\/:;\.,\?\*%\$£~“\)\[\]`\^@<>=\+!\/])+/, ' ').squish
    self[:valeur] = self[:valeur].strip.upcase.gsub(/(\s|["'\("#'\(&~,;:<>!\/\\\)\[\]\{\}\+=\-^\$\*@%§œ“Œ])+/, ' ').squish
  end
end
