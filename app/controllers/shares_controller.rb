class SharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shareable, only: [:create]
  before_action :set_share, only: [:accept, :decline]
  
  def create
    recipient_ids = params[:recipient_ids] || []
    @shareable = List.find(params[:shareable_id])
    
    shares = recipient_ids.map do |recipient_id|
      Share.new(
        creator: current_user,
        recipient_id: recipient_id,
        shareable: @shareable,
        permission: params[:share][:permission],
        reshareable: params[:share][:reshareable]
      )
    end
    
    if shares.all?(&:valid?)
      Share.transaction do
        shares.each do |share|
          share.save!
          ShareMailer.share_notification(share).deliver_later
        end
      end
      redirect_to list_path(id: @shareable.id), notice: t('.success')
    else
      errors = shares.map { |s| s.errors.full_messages }.flatten.uniq
      redirect_to list_path(id: @shareable.id), alert: errors.to_sentence
    end
  end
  
  def accept
    if @share.recipient == current_user
      @share.accepted!
      redirect_to lists_path, notice: t('.success')
    else
      redirect_to lists_path, alert: t('.unauthorized')
    end
  end
  
  def decline
    if @share.recipient == current_user
      @share.rejected!
      redirect_to lists_path, notice: t('.declined')
    else
      redirect_to lists_path, alert: t('.unauthorized')
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
  
  def set_share
    @share = Share.find(params[:id])
  end
  
  def share_params
    params.require(:share).permit(:recipient_id, :permission, :reshareable)
  end
end
