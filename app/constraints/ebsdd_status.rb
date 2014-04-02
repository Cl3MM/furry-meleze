class EbsddStatus
  def self.matches?(req)
    if req.path_parameters.has_key? :status
      [:expedies, :incomplets, :complets, :nouveau, :en_attente].include?(req.path_parameters[:status].to_sym)
    else
      false
    end
  end
end
