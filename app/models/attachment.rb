class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_many :ebsdds
  #before_save :content_type ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]

  has_mongoid_attached_file :attachment
  attr_accessible :attachment, :checksum, :attachment_fingerprint
  #field :attachment_fingerprint, type: String
  field :checksum, type: String

  def custom_save
    if check_content_type
      save
    else
      raise "Object invalide"
    end
  end
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
