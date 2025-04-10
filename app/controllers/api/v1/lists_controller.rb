module Api
  module V1
    class ListsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_list, only: [ :show, :update, :destroy ]
      before_action :ensure_editable, only: [ :update, :destroy ]

      def index
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        puts "=== DEBUG: ListsController#index ==="
        puts "Current.organization: #{Current.organization.inspect}"
        puts "Include shared parameter: #{params[:include].inspect}"

        begin
          # Get lists based on parameters
          if params[:include] == "shared"
            # Include all accessible lists (owned and shared)
            puts "Getting owned and shared lists"

            # Use a different approach - direct SQL to get both owned and shared lists
            owned_list_ids = Current.organization.lists.where(creator: current_user).pluck(:id)
            puts "Found #{owned_list_ids.size} owned lists"

            shared_list_ids = List.joins(:shares)
                            .where(shares: {
                              target_organization_id: Current.organization.id,
                              status: Share.statuses[:accepted]
                            }).pluck(:id)
            puts "Found #{shared_list_ids.size} shared lists"

            # Combine IDs and fetch all lists in one query
            all_ids = owned_list_ids + shared_list_ids
            puts "Total IDs: #{all_ids.size}"
            lists = List.where(id: all_ids)
            puts "Combined lists count: #{lists.count}"

          elsif params[:include] == "pending"
            # Only include pending shared lists
            puts "Getting pending shared lists"
            lists = List.joins(:shares)
                     .where(shares: {
                       target_organization_id: Current.organization.id,
                       status: Share.statuses[:pending]
                     })
          elsif params[:include] == "accepted"
            # Only include accepted shared lists
            puts "Getting accepted shared lists"
            lists = List.joins(:shares)
                     .where(shares: {
                       target_organization_id: Current.organization.id,
                       status: Share.statuses[:accepted]
                     })
          else
            # Default: Only include lists owned by the current user
            puts "Getting only owned lists"
            lists = Current.organization.lists.where(creator: current_user)
          end

          puts "Total lists: #{lists.count}"

          if lists.empty?
            render json: ListSerializer.render_collection(
              [],
              pagy: {
                current_page: 1,
                total_pages: 0,
                total_count: 0
              }
            )
          else
            # Apply search if query parameter exists
            if params[:search].present?
              search_condition = "LOWER(lists.name) LIKE :query OR LOWER(lists.description) LIKE :query"
              query_param = "%#{params[:search].downcase}%"
              lists = lists.where(search_condition, query: query_param)
            end

            # Apply sorting
            order_by = params[:order_by] || "created_at"
            order_direction = params[:order_direction] || "desc"
            lists = lists.order(order_by => order_direction)

            begin
              per_page = (params[:per_page] || 25).to_i
              pagy, records = pagy(lists, limit: per_page)
              render json: ListSerializer.render_collection(
                records,
                pagy: {
                  current_page: pagy.page,
                  total_pages: pagy.pages,
                  total_count: pagy.count
                }
              )
            rescue Pagy::OverflowError
              # If page is too high, return last page
              per_page = (params[:per_page] || 25).to_i
              last_page = (lists.count.to_f / per_page).ceil
              pagy, records = pagy(lists, limit: per_page, page: last_page)
              render json: ListSerializer.render_collection(
                records,
                pagy: {
                  current_page: pagy.page,
                  total_pages: pagy.pages,
                  total_count: pagy.count
                }
              )
            end
          end
        rescue => e
          puts "Error in index: #{e.message}"
          puts e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def show
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        puts "=== DEBUG: ListsController#show ==="
        puts "Current.organization: #{Current.organization.inspect}"
        puts "List ID: #{params[:id]}"

        begin
          render json: ListSerializer.render_success(@list)
        rescue => e
          Rails.logger.error "Error in show: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def create
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        puts "=== DEBUG: ListsController#create ==="
        puts "Current.organization: #{Current.organization.inspect}"
        puts "Params: #{params.inspect}"

        begin
          list = Current.organization.lists.build(list_params.merge(creator: current_user))
          puts "Built list: #{list.inspect}"
          puts "List valid? #{list.valid?}"
          puts "List errors: #{list.errors.full_messages}" unless list.valid?

          if list.save
            render json: ListSerializer.render_success(list), status: :created
          else
            puts "List save failed: #{list.errors.full_messages}"
            render json: BaseSerializer.render_validation_errors(list), status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error "Error in create: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def update
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        if @list.update(list_params)
          render json: ListSerializer.render_success(@list)
        else
          render json: BaseSerializer.render_validation_errors(@list), status: :unprocessable_entity
        end
      rescue => e
        render_error(e.message)
      end

      def destroy
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        ActiveRecord::Base.transaction do
          if @list.destroy
            head :no_content
          else
            render_error("Failed to delete list")
          end
        end
      rescue => e
        render_error(e.message)
      end

      # Share management endpoints
      def accept_share
        puts "=== DEBUG: ListsController#accept_share ==="
        puts "List ID: #{params[:id]}"
        puts "Current organization: #{Current.organization&.id}"

        # First check if the list exists
        list = List.find_by(id: params[:id])
        puts "List found: #{list.present?}"

        if list.nil?
          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "List not found" } ]
          }, status: :not_found
          return
        end

        # Now find the share record
        share = Share.find_by(
          shareable: list,
          target_organization: Current.organization,
          status: :pending
        )
        puts "Share found: #{share.present?}"

        if share.nil?
          # Let's debug why the share isn't found
          all_shares = Share.where(shareable: list)
          puts "All shares for this list:"
          all_shares.each do |s|
            puts "  - ID: #{s.id}, target_org: #{s.target_organization_id}, source_org: #{s.source_organization_id}, status: #{s.status}"
          end

          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "Share not found" } ]
          }, status: :not_found
          return
        end

        # Update the share status
        share.accepted!
        puts "Share updated to accepted"

        render json: ListSerializer.render_success(list)
      rescue => e
        puts "Error in accept_share: #{e.message}"
        puts e.backtrace.join("\n")
        render_error(e.message)
      end

      def decline_share
        puts "=== DEBUG: ListsController#decline_share ==="
        puts "List ID: #{params[:id]}"
        puts "Current organization: #{Current.organization&.id}"

        list = List.find_by(id: params[:id])
        puts "List found: #{list.present?}"

        if list.nil?
          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "List not found" } ]
          }, status: :not_found
          return
        end

        share = Share.find_by(
          shareable: list,
          target_organization: Current.organization,
          status: :pending
        )
        puts "Share found: #{share.present?}"

        if share.nil?
          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "Share not found" } ]
          }, status: :not_found
          return
        end

        share.destroy
        puts "Share destroyed"

        head :no_content
      rescue => e
        puts "Error in decline_share: #{e.message}"
        puts e.backtrace.join("\n")
        render_error(e.message)
      end

      def remove_share
        puts "=== DEBUG: ListsController#remove_share ==="
        puts "List ID: #{params[:id]}"
        puts "Current organization: #{Current.organization&.id}"

        # Instead of using accessible_by, find the list directly
        list = List.find_by(id: params[:id])
        puts "List found: #{list.present?}"
        puts "List details: #{list.inspect}" if list

        if list.nil?
          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "List not found" } ]
          }, status: :not_found
          return
        end

        # Find share by list and target_organization
        share = Share.find_by(
          shareable_type: "List",
          shareable_id: list.id,
          target_organization_id: Current.organization.id
        )
        puts "Share found: #{share.present?}"
        puts "Share details: #{share.inspect}" if share

        if share.nil?
          # Let's debug why the share isn't found
          all_shares = Share.where(shareable_type: "List", shareable_id: list.id)
          puts "All shares for this list (#{all_shares.count}):"
          all_shares.each do |s|
            puts "  - ID: #{s.id}, target_org: #{s.target_organization_id}, source_org: #{s.source_organization_id}, status: #{s.status}"
          end

          render json: {
            status: "error",
            errors: [ { code: "not_found", detail: "Share not found" } ]
          }, status: :not_found
          return
        end

        share.destroy
        puts "Share destroyed successfully"

        head :no_content
      rescue => e
        puts "Error in remove_share: #{e.message}"
        puts e.backtrace.join("\n")
        render_error(e.message)
      end

      private

      def render_unauthorized
        render json: {
          status: "error",
          errors: [ {
            code: "unauthorized",
            detail: "You need to sign in or sign up before continuing."
          } ]
        }, status: :unauthorized
      end

      def set_list
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end

        puts "=== DEBUG: ListsController#set_list ==="
        puts "List ID: #{params[:id]}"
        puts "Current organization: #{Current.organization.id}"
        puts "Current user: #{current_user.id}"

        # First check if this is a list directly owned by the current organization
        owned_list = Current.organization.lists.find_by(id: params[:id])

        if owned_list
          @list = owned_list
          puts "Found owned list: #{@list.inspect}"
          return
        end

        # If not owned, check if it's a list shared with the current organization
        shared_list = List.joins(:shares)
          .where(
            id: params[:id],
            shares: {
              target_organization_id: Current.organization.id,
              status: Share.statuses[:accepted]
            }
          ).first

        if shared_list
          @list = shared_list
          puts "Found shared list: #{@list.inspect}"
          return
        end

        # If we get here, the list wasn't found
        puts "List not found with ID #{params[:id]}"
        render json: {
          status: "error",
          errors: [ {
            code: "not_found",
            detail: "List not found"
          } ]
        }, status: :not_found
      end

      def ensure_editable
        unless action_name == "destroy" ? @list.deletable_by?(current_user) : @list.editable_by?(current_user)
          render json: {
            status: "error",
            errors: [ {
              code: "forbidden",
              detail: "You are not authorized to perform this action"
            } ]
          }, status: :forbidden
        end
      end

      def list_params
        params.require(:list).permit(:name, :description, :visibility)
      end
    end
  end
end
