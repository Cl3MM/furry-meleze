module EbsddsHelper
  def date_transport
    @ebsdd.bordereau_date_transport.strftime("%d-%m-%Y") unless @ebsdd.bordereau_date_transport.nil?
  end

  def safe_date attr
    @ebsdd[attr.to_sym].strftime("%d-%m-%Y") unless @ebsdd[attr.to_sym].nil?
  end
end

