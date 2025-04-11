class ListRestaurantsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  before_action :set_list
  before_action :ensure_editable, except: [ :import, :import_all ]
  include Pagy::Backend

  def index
    @pagy, @restaurants = pagy(
      Current.organization.restaurants.search_by_full_text(params[:query])
        .includes(:cuisine_type)
        .order(:name)
    )

    render :new
  end

  def new
    @pagy, @restaurants = pagy(
      Current.organization.restaurants.search_by_full_text(params[:query])
        .includes(:cuisine_type)
        .order(:name)
    )
  end

  def create
    @list_restaurant = @list.list_restaurants.build(restaurant_id: params[:restaurant_id])

    if @list_restaurant.save
      redirect_to list_path(id: @list.id), notice: t(".success")
    else
      redirect_to list_path(id: @list.id), alert: t(".error")
    end
  end

  def destroy
    @list_restaurant = @list.list_restaurants.find(params[:id])
    @list_restaurant.destroy

    flash[:notice] = t(".success")
    redirect_to edit_list_list_restaurants_path(list_id: @list.id)
  end

  def import_all
    restaurants_to_import = @list.restaurants.where.not(
      id: RestaurantCopy.where(organization: Current.organization).select(:restaurant_id)
    )

    imported_count = 0

    ActiveRecord::Base.transaction do
      restaurants_to_import.each do |restaurant|
        copied_restaurant = restaurant.copy_for_organization(Current.organization)
        imported_count += 1 if copied_restaurant.persisted?
      end
    end

    respond_to do |format|
      format.html do
        redirect_to list_path(id: @list.id),
          notice: t(".success", count: imported_count)
      end
      format.turbo_stream do
        flash.now[:notice] = t(".success", count: imported_count)
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :ok
      end
    end
  end

  def import
    restaurant = @list.restaurants.find(params[:id])
    copied_restaurant = restaurant.copy_for_organization(Current.organization)

    respond_to do |format|
      format.html do
        if copied_restaurant.persisted?
          redirect_to list_path(id: @list.id), notice: t(".success")
        else
          redirect_to list_path(id: @list.id), alert: t(".error")
        end
      end
      format.turbo_stream do
        if copied_restaurant.persisted?
          flash.now[:notice] = t(".success")
          render turbo_stream: [
            turbo_stream.replace(
              dom_id(restaurant, :import),
              partial: "lists/restaurant_imported",
              locals: { restaurant: restaurant }
            ),
            turbo_stream.update("flash", partial: "shared/flash")
          ]
        else
          flash.now[:alert] = t(".error")
          render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
        end
      end
    end
  end

  private

  def set_list
    # Find list that is either owned by or shared with the current organization
    @list = List.find(params[:list_id])

    # Check if the list is viewable by the current organization
    unless @list.viewable_by?(Current.organization)
      raise ActiveRecord::RecordNotFound
    end
  rescue ActiveRecord::RecordNotFound
    render file: Rails.root.join("public", "404.html").to_s, status: :not_found, layout: false
  end

  def ensure_editable
    unless @list.editable_by?(Current.organization)
      redirect_to list_path(id: @list.id), alert: t(".not_authorized")
    end
  end
end
