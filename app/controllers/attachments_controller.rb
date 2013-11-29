class AttachmentsController < ApplicationController
  def index
    @attachments = Attachment.all
  end
  def show
    @attachment = Attachment.find_or_initialize_by(id: params[:id])
    @ebsdds = @attachment.ebsdds.paginate(page: params[:page], per_page: 15)
  end
end
