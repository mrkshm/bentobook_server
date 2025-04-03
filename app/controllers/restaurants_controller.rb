class RestaurantsController < ApplicationController
  include ActionView::RecordIdentifier
  include RestaurantManagement
  include Pagy::Backend
  include CuisineTypeValidation

  before_action :authenticate_user!
  before_action :set_restaurant, only: [ :show, :edit, :update, :destroy, :update_price_level, :edit_images ]

  def index
    order_params = parse_order_params
    return if performed?

    items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 12
    page = params[:page].to_i.positive? ? params[:page].to_i : 1

    restaurants_scope = Current.organization.restaurants.with_google.includes(:visits, :cuisine_type, :tags)
    query_params = search_params.merge(order_params)
    @restaurants = RestaurantQuery.new(restaurants_scope, query_params).call
    @pagy, @restaurants = pagy_countless(@restaurants, items: items_per_page, page: page)
    @tags = ActsAsTaggableOn::Tag.most_used(10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id])
    @notes_edit = params[:notes_edit].present?
    @tags = @restaurant.tags || []

    # Handle specific turbo frame request for notes
    if turbo_frame_request? && request.headers["Turbo-Frame"] == "restaurant_#{@restaurant.id}_notes"
      render partial: "components/notes_component", locals: {
        record: @restaurant,
        notes_field: :notes,
        container_classes: "mt-4",
        notes_edit: @notes_edit
      }
      return
    end

    @all_tags = ActsAsTaggableOn::Tag.all
    @visits = @restaurant.visits

    if params[:modal] == "cuisine_type"
      Rails.logger.debug "Rendering cuisine type modal"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "modal",
            partial: "restaurants/cuisine_type_modal",
            locals: { restaurant: @restaurant }
          )
        end
        format.html
      end
      return
    end

    list_restaurants = ListRestaurant.where(restaurant_id: @restaurant.id)
    lists = List.where(id: list_restaurants.pluck(:list_id))
    @lists = List.accessible_by(Current.organization).containing_restaurant(@restaurant)

    if turbo_frame_request? && params[:turbo_frame] == dom_id(@restaurant, :notes)
      render partial: "components/notes_component", locals: {
        record: @restaurant,
        notes_field: :notes,
        container_classes: nil,
        notes_edit: @notes_edit
      }
    end
  end

  def edit
    @restaurant = Current.organization.restaurants.with_google.includes(:images).find(params[:id])
    @cuisine_types = CuisineType.all
    Rails.logger.debug "Cuisine types: #{@cuisine_types.inspect}"
  end

  def new
  end

  def new_confirm
    @google_restaurant = Restaurants::GooglePlaceImportService.find_or_create(place_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("restaurant_search", ""),
          turbo_stream.update(
            "restaurant_form",
            partial: "restaurants/new/restaurant_confirm",
            locals: { google_restaurant: @google_restaurant }
          )
        ]
      end
    end
  end

  def edit_images
    @images = @restaurant.images.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.turbo_stream # For Hotwire Native modal support
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      respond_to do |format|
        format.turbo_stream do
          if restaurant_params.key?(:price_level)
            render turbo_stream: [
              turbo_stream.replace(
                dom_id(@restaurant, :price_level),
                partial: "restaurants/price_level",
                locals: { restaurant: @restaurant }
              ),
              turbo_stream.replace(
                "#{dom_id(@restaurant, :price_level)}_modal_container",
                partial: "restaurants/price_level_modal",
                locals: { restaurant: @restaurant }
              )
            ]
          elsif restaurant_params.key?(:cuisine_type_id)
            render turbo_stream: [
              turbo_stream.update("modal", ""),
              turbo_stream.replace(
                dom_id(@restaurant, :cuisine_type),
                partial: "restaurants/cuisine_type",
                locals: { restaurant: @restaurant }
              )
            ]
          end
        end
        format.html { redirect_to @restaurant }
        format.json { render json: @restaurant }
      end
    else
      head :unprocessable_entity
    end
  end

  def update_price_level
    @restaurant = Current.organization.restaurants.find(params[:id])

    if @restaurant.update(price_level: params[:restaurant][:price_level])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :price_level),
            partial: "restaurants/price_level",
            locals: { restaurant: @restaurant }
          )
        end
        format.html { redirect_to @restaurant }
        format.json { render json: { status: :ok, price_level: @restaurant.price_level } }
      end
    else
      head :unprocessable_entity
    end
  end

  def create
    google_restaurant = GoogleRestaurant.find(params[:restaurant][:google_restaurant_id])
    @restaurant, status = Restaurants::StubCreatorService.create(
      user: current_user,
      google_restaurant: google_restaurant
    )

    flash_type = status == :new ? :success : :info
    notice_key = status == :new ? "restaurants.created" : "restaurants.already_exists"
    redirect_to restaurant_path(id: @restaurant.id, locale: current_locale),
                flash: { flash_type => t(notice_key) }
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = t("restaurants.errors.google_restaurant_not_found")
    redirect_to new_restaurant_path
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to new_restaurant_path
  end

  def destroy
    @restaurant.destroy
    redirect_to restaurants_path, notice: "Restaurant was successfully removed from your list."
  end

  def search
    respond_to do |format|
      format.html { render partial: "search_form" }
      format.turbo_stream
    end
  end

  private

  def render_error_response
    if hotwire_native_app?
      render :edit_tags_native, status: :unprocessable_entity
    else
      render :edit_tags, status: :unprocessable_entity
    end
  end

  def parse_order_params
    order_field = params[:order_by] || RestaurantQuery::DEFAULT_ORDER[:field]
    order_direction = params[:order_direction] || RestaurantQuery::DEFAULT_ORDER[:direction]

    unless RestaurantQuery::ALLOWED_ORDER_FIELDS.include?(order_field)
      flash[:alert] = "Invalid order_by parameter. Using default sorting."
      order_field = RestaurantQuery::DEFAULT_ORDER[:field]
    end

    unless valid_order_direction?(order_direction)
      flash[:alert] = "Invalid order_direction parameter. Using default direction."
      order_direction = RestaurantQuery::DEFAULT_ORDER[:direction]
    end

    { order_by: order_field, order_direction: order_direction }
  end

  def valid_order_direction?(direction)
    [ "asc", "desc" ].include?(direction.to_s.downcase)
  end

  def search_params
    params.permit(:search, :tag, :latitude, :longitude, :order_by, :order_direction).merge(organization: Current.organization)
  end

  def restaurant_params
    # First get the regular permitted params
    permitted = params.require(:restaurant).permit(
      :name, :address, :notes, :cuisine_type_name, :cuisine_type_id,
      :rating, :price_level, :street_number, :street, :postal_code,
      :city, :state, :country, :phone_number, :url, :business_status,
      :tag_list, images: [],
      google_restaurant_attributes: [
        :google_place_id, :name, :address, :latitude, :longitude,
        :street_number, :street, :postal_code, :city, :state, :country,
        :phone_number, :url, :business_status, :google_rating,
        :google_ratings_total, :price_level, :opening_hours, :google_updated_at
      ],
      tags: []
    )

    # Handle the special case of images - filter out any empty strings or nil values
    if permitted[:images].present?
      # Only keep actual file uploads, reject empty strings and nil values
      permitted[:images] = Array(permitted[:images]).reject(&:blank?).select do |img|
        img.is_a?(ActionDispatch::Http::UploadedFile) && img.size.positive?
      end

      # If after filtering we have an empty array, remove the key entirely
      permitted.delete(:images) if permitted[:images].empty?
    end

    permitted
  end

  def restaurant_update_params
    params.require(:restaurant).permit(
      :name, :address, :notes, :cuisine_type_id, :cuisine_type_name,
      :rating, :price_level, :street_number, :street, :postal_code,
      :city, :state, :country, :phone_number, :url, :business_status,
      :tag_list, images: []
    ).tap do |whitelisted|
      Rails.logger.info "Whitelisted params: #{whitelisted.inspect}"
    end
  end

  def handle_failed_save
    @cuisine_types = CuisineType.all
    flash[:alert] = if @restaurant&.errors&.any?
                      @restaurant.errors.full_messages.join(", ")
    else
                      flash[:alert] # Keep existing flash message if no restaurant errors
    end
    render :new, status: :unprocessable_entity
  end

  def handle_invalid_cuisine_type
    @cuisine_types = CuisineType.all
    flash[:alert] = "Invalid cuisine type: #{restaurant_params[:cuisine_type_name]}. Available types: #{@cuisine_types.pluck(:name).join(', ')}"
    render :new, status: :unprocessable_entity
  end

  def set_restaurant
    # Use params[:restaurant_id] if it exists, otherwise fall back to params[:id]
    id = params[:restaurant_id] || params[:id]
    @restaurant = Current.organization.restaurants.find(id)
  end

  def place_params
    params.require(:place).permit(
      :google_place_id, :name, :formatted_address, :latitude, :longitude,
      :phone_number, :website, :rating, :user_ratings_total,
      :price_level, :business_status, :street_number, :street_name,
      :city, :state, :postal_code, :country
    )
  end
end
