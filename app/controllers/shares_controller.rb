class SharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shareable, only: [:create]
  
  def create
    @share = Share.new(share_params)
    @share.creator = current_user
    @share.shareable = @shareable
    
    if @share.save
      # TODO: Send notification email
      redirect_to list_path(id: @shareable.id), notice: t('.success')
    else
      redirect_to list_path(id: @shareable.id), alert: @share.errors.full_messages.to_sentence
    end
  end
  
  private
  
  def set_shareable
    shareable_type = params[:shareable_type].classify
    shareable_id = params[:shareable_id]
    
    @shareable = shareable_type.constantize.find(shareable_id)
  rescue NameError, ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('.invalid_shareable')
  end
  
  def share_params
    params.require(:share).permit(:recipient_id, :permission)
  end
end
