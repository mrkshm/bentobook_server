class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_editable, only: [ :edit, :update, :destroy ]

  def index
    @order_by = params[:order_by] || "created_at"
    @order_direction = params[:order_direction] || "desc"
    @query = params[:search]

    @lists = Current.organization.lists.where(creator: current_user)
    @pending_lists = user_signed_in? ? current_user.shared_lists.pending.where(organization: Current.organization) : []
    @accepted_lists = user_signed_in? ? current_user.shared_lists.accepted.where(organization: Current.organization) : []

    if @query.present?
      search_condition = "LOWER(lists.name) LIKE :query OR LOWER(lists.description) LIKE :query"
      query_param = "%#{@query.downcase}%"

      @lists = @lists.where(search_condition, query: query_param)
      @pending_lists = @pending_lists.where(search_condition, query: query_param)
      @accepted_lists = @accepted_lists.where(search_condition, query: query_param)
    end

    @sort_fields = {
      "name" => t("lists.name"),
      "created_at" => t("common.sort.recently_added"),
      "updated_at" => t("common.sort.recently_updated")
    }
  end

  def show
    @order_by = params[:order_by] || "name"
    @order_direction = params[:order_direction] || "asc"
    @statistics = ListStatistics.new(list: @list, user: current_user)

    @restaurants = @list.restaurants
      .includes(:cuisine_type)
      .order(@order_by => @order_direction)

    @sort_fields = {
      "name" => t("restaurants.name"),
      "cuisine_types.name" => t("restaurants.attributes.cuisine_type"),
      "created_at" => t("common.sort.recently_added")
    }
  end

  def new
    @list = Current.organization.lists.build(creator: current_user)
  end

  def create
    @list = Current.organization.lists.build(list_params.merge(creator: current_user))

    if @list.save
      redirect_to list_path(id: @list.id), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to list_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      if @list.destroy
        redirect_to lists_path, notice: t(".success"), status: :see_other
      else
        redirect_to list_path(@list), alert: t(".failure")
      end
    end
  rescue => e
    Rails.logger.error "Failed to delete list: #{e.message}"
    redirect_to list_path(@list), alert: t(".failure")
  end

  def export
    @list = Current.organization.lists.accessible_by(current_user).find(params[:id])

    respond_to do |format|
      format.text do
        content = ListMarkdownExporter.new(@list).generate
        response.headers["Content-Type"] = "text/markdown"
        response.headers["Content-Disposition"] = "attachment; filename=\"#{@list.name.parameterize}-restaurants.md\""
        render plain: content
      end

      format.turbo_stream do
        if params[:email].present?
          options = {
            include_stats: params[:include_stats] == "1",
            include_notes: params[:include_notes] == "1"
          }

          ListMailer.export(@list, params[:email], options).deliver_later

          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.append("flash",
              partial: "shared/flash",
              locals: { flash: { success: t(".email_sent", email: params[:email], list: @list.name) } })
          ]
        end
      end

      format.html do
        if params[:email].present?
          redirect_to list_path(id: @list.id),
                      success: t(".email_sent", email: params[:email], list: @list.name)
        else
          render :export_modal, layout: false
        end
      end
    end
  end

  def share
    @list = Current.organization.lists.accessible_by(current_user).find(params[:id])
    @share = Share.new
    render :_share_modal, layout: false
  end

  def remove_share
    @list = Current.organization.lists.accessible_by(current_user).find(params[:id])
    share = current_user.shares.find_by!(shareable: @list)
    share.destroy

    redirect_to lists_path, notice: t(".share_removed")
  end

  def accept_share
    @list = Current.organization.lists.find_by!(id: params[:id])
    share = current_user.shares.find_by!(shareable: @list)
    share.accepted!

    respond_to do |format|
      format.html { redirect_to lists_path, notice: t(".share_accepted") }
      format.turbo_stream do
        flash.now[:notice] = t(".share_accepted")
        render turbo_stream: [
          turbo_stream.remove(helpers.dom_id(share)),
          turbo_stream.append("shared-lists-grid", partial: "lists/shared_list", locals: { list: @list }),
          turbo_stream.replace("pending-lists-section", partial: "lists/pending_lists_section", locals: {
            pending_lists: current_user.shared_lists.pending.where(organization: Current.organization).includes(:owner, owner: { profile: { avatar_attachment: :blob } }),
            current_user: current_user
          }),
          turbo_stream.replace("shared-lists-section", partial: "lists/shared_lists_section", locals: {
            accepted_lists: current_user.shared_lists.accepted.where(organization: Current.organization).includes(:owner, owner: { profile: { avatar_attachment: :blob } }),
            current_user: current_user
          }),
          turbo_stream.update("flash", partial: "shared/flash")
        ]
      end
    end
  end

  def decline_share
    @list = Current.organization.lists.find_by!(id: params[:id])
    share = current_user.shares.find_by!(shareable: @list)
    share.destroy

    respond_to do |format|
      format.html { redirect_to lists_path, notice: t(".share_declined") }
      format.turbo_stream do
        flash.now[:notice] = t(".share_declined")
        render turbo_stream: [
          turbo_stream.remove(helpers.dom_id(share)),
          turbo_stream.update("flash", partial: "shared/flash")
        ]
      end
    end
  end

  private

  def set_list
    @list = Current.organization.lists
             .left_joins(:shares)
             .where(
               "lists.creator_id = :user_id OR " \
               "(shares.recipient_id = :user_id AND shares.status = :accepted)",
               user_id: current_user.id,
               accepted: Share.statuses[:accepted]
             )
             .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to lists_path, alert: t(".not_found")
  end

  def ensure_editable
    unless action_name == "destroy" ? @list.deletable_by?(current_user) : @list.editable_by?(current_user)
      redirect_to list_path(@list), alert: t(".not_authorized")
    end
  end

  def list_params
    params.require(:list).permit(:name, :description, :visibility)
  end
end
