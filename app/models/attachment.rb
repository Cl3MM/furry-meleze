class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  def self.per_page
    2
  end

  has_many :ebsdds
  #before_save :content_type ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]

  has_mongoid_attached_file :attachment

  validates_attachment :attachment, presence: true, content_type: { content_type: ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "text/csv"] }

  attr_accessible :attachment, :checksum, :failed, :exec_time, :total, :producteurs
  field :checksum, type: String
  field :failed, type: Array
  field :producteurs, type: Array
  field :exec_time, type: Float
  field :total, type: Integer

  def items
    ebsdds.count
  end
  #def custom_save
    #if check_content_type
      #save
    #else
      #raise "Object invalide"
    #end
  #end
  protected
  def check_content_type
    content_type ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
  end
  def content_type type
    if type.is_a? String
      attachment_content_type == type
    elsif type.is_a? Array
      type.include? attachment_content_type
    else
      false
    end
  end
end
