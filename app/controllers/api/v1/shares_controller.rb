module Api
  module V1
    class SharesController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_share, only: [ :accept, :decline, :destroy ]
      before_action :authorize_list_sharing!, only: [ :create ]

      def index
        # Get shares where the user's organizations are the target
        Rails.logger.debug "=== DEBUG: SharesController#index ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        shares = Share.where(target_organization: Current.organization)
                      .includes(:creator, :source_organization, :target_organization, :shareable)
        
        Rails.logger.debug "Found shares: #{shares.count}"
        Rails.logger.debug "Shares: #{shares.inspect}"
        
        begin
          json = ShareSerializer.render_collection(shares)
          Rails.logger.debug "JSON: #{json.inspect}"
          render json: json
        rescue => e
          Rails.logger.error "Error rendering JSON: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: e.message }, status: :internal_server_error
        end
      rescue => e
        Rails.logger.error "Error in SharesController#index: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def create
        Rails.logger.debug "=== DEBUG: SharesController#create ==="
        Rails.logger.debug "Params: #{params.inspect}"
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        # Extract target organization IDs from params
        target_organization_ids = params[:target_organization_ids] || []
        Rails.logger.debug "Target organization IDs: #{target_organization_ids.inspect}"

        # Ensure target_organization_ids is an array of strings or integers
        target_organization_ids = Array(target_organization_ids).map(&:to_s)
        Rails.logger.debug "Processed target organization IDs: #{target_organization_ids.inspect}"

        # Skip shares creation if no target organizations specified
        if target_organization_ids.empty?
          render json: { error: "No target organizations specified" }, status: :unprocessable_entity
          return
        end

        shares = target_organization_ids.map do |target_organization_id|
          Rails.logger.debug "Creating share for target_organization_id: #{target_organization_id}"
          share = Share.new(
            creator: current_user,
            source_organization: Current.organization,
            target_organization_id: target_organization_id,
            shareable: @shareable,
            permission: share_params[:permission],
            reshareable: share_params[:reshareable]
          )
          Rails.logger.debug "Share valid? #{share.valid?}"
          Rails.logger.debug "Share errors: #{share.errors.full_messages}" unless share.valid?
          share
        end

        Rails.logger.debug "Created shares: #{shares.count}"
        Rails.logger.debug "All valid? #{shares.all?(&:valid?)}"

        if shares.all?(&:valid?) && shares.any?
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
      rescue => e
        Rails.logger.error "Error in SharesController#create: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def accept
        Rails.logger.debug "=== DEBUG: SharesController#accept ==="
        Rails.logger.debug "Share: #{@share.inspect}"
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        if @share.target_organization == Current.organization
          @share.accepted!
          render json: ShareSerializer.render_success(@share)
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      rescue => e
        Rails.logger.error "Error in SharesController#accept: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def decline
        Rails.logger.debug "=== DEBUG: SharesController#decline ==="
        Rails.logger.debug "Share: #{@share.inspect}"
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        if @share.target_organization == Current.organization
          @share.rejected!
          render json: ShareSerializer.render_success(@share)
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      rescue => e
        Rails.logger.error "Error in SharesController#decline: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def accept_all
        Rails.logger.debug "=== DEBUG: SharesController#accept_all ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        shares = Share.where(target_organization: Current.organization, status: :pending)
        Rails.logger.debug "Found shares: #{shares.count}"

        if shares.any?
          Share.transaction do
            shares.each(&:accepted!)
          end
          render json: ShareSerializer.render_collection(shares)
        else
          render json: { message: "No pending shares to accept" }, status: :ok
        end
      rescue => e
        Rails.logger.error "Error in SharesController#accept_all: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def decline_all
        Rails.logger.debug "=== DEBUG: SharesController#decline_all ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        shares = Share.where(target_organization: Current.organization, status: :pending)
        Rails.logger.debug "Found shares: #{shares.count}"

        if shares.any?
          Share.transaction do
            shares.each(&:rejected!)
          end
          render json: ShareSerializer.render_collection(shares)
        else
          render json: { message: "No pending shares to decline" }, status: :ok
        end
      rescue => e
        Rails.logger.error "Error in SharesController#decline_all: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      def destroy
        Rails.logger.debug "=== DEBUG: SharesController#destroy ==="
        Rails.logger.debug "Share: #{@share.inspect}"
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        if @share.creator == current_user || 
           @share.source_organization == Current.organization || 
           @share.target_organization == Current.organization
          @share.destroy
          head :no_content
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      rescue => e
        Rails.logger.error "Error in SharesController#destroy: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def set_share
        @share = Share.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "Error in SharesController#set_share: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: "Share not found" }, status: :not_found
      end

      def share_params
        params.require(:share).permit(:permission, :reshareable)
      rescue ActionController::ParameterMissing => e
        Rails.logger.error "Error in SharesController#share_params: #{e.message}"
        # Default values if share params are missing
        { permission: 'view', reshareable: false }
      end

      def authorize_list_sharing!
        Rails.logger.debug "=== DEBUG: SharesController#authorize_list_sharing! ==="
        Rails.logger.debug "Params: #{params.inspect}"
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        
        begin
          @shareable = List.find(params[:list_id])
          Rails.logger.debug "Shareable: #{@shareable.inspect}"
          Rails.logger.debug "Shareable organization: #{@shareable.organization.inspect}"
          
          authorized = @shareable.organization == Current.organization ||
                      (@shareable.shares.accepted.exists?(
                        target_organization: Current.organization, 
                        permission: :edit, 
                        reshareable: true
                      ))
          
          Rails.logger.debug "Authorized: #{authorized}"

          unless authorized
            render json: { error: "You don't have permission to share this list" },
                   status: :unauthorized
            return false
          end
          
          return true
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.error "Error in SharesController#authorize_list_sharing!: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "List not found" }, status: :not_found
          return false
        rescue => e
          Rails.logger.error "Error in SharesController#authorize_list_sharing!: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: e.message }, status: :internal_server_error
          return false
        end
      end
    end
  end
end
