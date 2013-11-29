class DashboardController < ApplicationController
  before_filter :authenticate_utilisateur!

  def index
    @ebsdds       = Ebsdd.all
    @attachments  = Attachment.all
  end
end
