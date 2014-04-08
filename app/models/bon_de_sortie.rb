# encoding: utf-8
class BonDeSortie
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ebsdds, autosave: true
  belongs_to :destination
  #attr_accessible :id, :_id
  field :_id, type: String, default: ->{ "#{Time.now.strftime("%y%m%d")}BDS#{"%04d" % BonDeSortie.count}" }

end
