module Api
  module V1
    class SharesController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_share, only: [ :accept, :decline, :destroy ]
      before_action :authorize_list_sharing!, only: [ :create ]

      def index
        shares = current_user.shares.includes(:creator, :recipient, :shareable)
        render json: ShareSerializer.render_collection(shares)
      end

      def create
        recipient_ids = params[:recipient_ids] || []

        @shareable = List.find(params[:list_id])

        shares = recipient_ids.map do |recipient_id|
          Share.new(
            creator: current_user,
            recipient_id: recipient_id,
            shareable: @shareable,
            permission: share_params[:permission],
            reshareable: share_params[:reshareable]
          )
        end

        if shares.all?(&:valid?)
          Share.transaction do
            shares.each do |share|
              share.save!
              ShareMailer.share_notification(share).deliver_later
            end
          end
          render json: ShareSerializer.render_collection(shares), status: :created
        else
          errors = shares.map { |s| s.errors.full_messages }.flatten.uniq
          render json: { errors: errors }, status: :unprocessable_entity
        end
      end

      def accept
        if @share.recipient == current_user
          @share.accepted!
          render json: ShareSerializer.render_success(@share)
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def decline
        if @share.recipient == current_user
          @share.rejected!
          render json: ShareSerializer.render_success(@share)
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def accept_all
        shares = current_user.shares.pending

        if shares.any?
          Share.transaction do
            shares.each(&:accepted!)
          end
          render json: ShareSerializer.render_collection(shares)
        else
          render json: { message: "No pending shares to accept" }, status: :ok
        end
      end

      def decline_all
        shares = current_user.shares.pending

        if shares.any?
          Share.transaction do
            shares.each(&:rejected!)
          end
          render json: ShareSerializer.render_collection(shares)
        else
          render json: { message: "No pending shares to decline" }, status: :ok
        end
      end

      def destroy
        if @share.creator == current_user || @share.recipient == current_user
          @share.destroy
          head :no_content
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      private

      def set_share
        @share = Share.find(params[:id])
      end

      def share_params
        params.require(:share).permit(:permission, :reshareable)
      end

      def authorize_list_sharing!
        @shareable = List.find(params[:list_id])

        unless @shareable.owner == current_user ||
               (@shareable.shares.accepted.exists?(recipient: current_user, permission: :edit, reshareable: true))
          render json: { error: "You don't have permission to share this list" },
                 status: :unauthorized
        end
      end
    end
  end
end
