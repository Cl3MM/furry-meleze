class DashboardController < ApplicationController
  before_filter :authenticate_utilisateur!

  def index
    @nouveaux  = Ebsdd.where(status: :nouveau).limit(10)
    @en_attente  = Ebsdd.where(status: :en_attente).limit(10)
    @incomplete  = Ebsdd.where(status: :incomplet).limit(10)
    @complete    = Ebsdd.where(status: :complet).limit(10)
    @attachments = Attachment.all.limit(5)
    @alertes     = Ebsdd.seuils
  end
end

