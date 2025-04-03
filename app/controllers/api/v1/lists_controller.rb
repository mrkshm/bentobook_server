module Api
  module V1
    class ListsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_list, only: [ :update, :destroy ]

      def index
        lists = if params[:include]&.include?("shared")
                 Current.organization.lists.accessible_by(current_user).includes(:restaurants)
        else
                 Current.organization.lists.where(creator: current_user).includes(:restaurants)
        end

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
        render_error(e.message)
      end

      def show
        list = Current.organization.lists.accessible_by(current_user).includes(:restaurants).find(params[:id])
        render json: ListSerializer.render_success(list)
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          errors: [ {
            code: "not_found",
            detail: "List not found"
          } ]
        }, status: :not_found
      rescue => e
        render_error(e.message)
      end

      def create
        list = Current.organization.lists.build(list_params.merge(creator: current_user))
        if list.save
          render json: ListSerializer.render_success(list), status: :created
        else
          render json: BaseSerializer.render_validation_errors(list), status: :unprocessable_entity
        end
      rescue => e
        render_error(e.message)
      end

      def update
        if @list.update(list_params)
          render json: ListSerializer.render_success(@list)
        else
          render json: BaseSerializer.render_validation_errors(@list), status: :unprocessable_entity
        end
      rescue => e
        render_error(e.message)
      end

      def destroy
        @list.destroy
        head :no_content
      rescue => e
        render_error(e.message)
      end

      private

      def set_list
        @list = Current.organization.lists.where(creator: current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          errors: [ {
            code: "not_found",
            detail: "List not found"
          } ]
        }, status: :not_found
      end

      def list_params
        params.require(:list).permit(:name, :description, :visibility, :premium, :position)
      end
    end
  end
end
