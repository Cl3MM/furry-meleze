class DashboardController < ApplicationController
  before_filter :authenticate_utilisateur!

  def index
    @incomplete  = Ebsdd.where(status: :incomplet).limit(10)
    @complete    = Ebsdd.where(status: :complet).limit(10)
    @attachments = Attachment.all.limit(5)
  end
end
