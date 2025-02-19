class RestaurantsController < ApplicationController
  include ActionView::RecordIdentifier
  include RestaurantManagement
  include Pagy::Backend
  include CuisineTypeValidation

  before_action :authenticate_user!
  before_action :set_restaurant, only: [ :show, :edit, :update, :destroy, :add_tag, :remove_tag, :update_rating ]

  def index
    order_params = parse_order_params
    return if performed?

    items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10

    restaurants_scope = current_user.restaurants.with_google.includes(:visits, :cuisine_type, :tags)

    query_params = search_params.merge(order_params)
    @restaurants = RestaurantQuery.new(restaurants_scope, query_params).call
    @pagy, @restaurants = pagy(@restaurants, items: items_per_page)

    @tags = ActsAsTaggableOn::Tag.most_used(10)
  end

  def show
    @tags = @restaurant.tags
    @all_tags = ActsAsTaggableOn::Tag.all
    @visits = @restaurant.visits

    list_restaurants = ListRestaurant.where(restaurant_id: @restaurant.id)
    lists = List.where(id: list_restaurants.pluck(:list_id))
    @lists = List.accessible_by(current_user).containing_restaurant(@restaurant)
  end

  def edit
    @restaurant = current_user.restaurants.with_google.includes(:images).find(params[:id])
    @cuisine_types = CuisineType.all
    Rails.logger.debug "Cuisine types: #{@cuisine_types.inspect}"
  end

  def new
    @restaurant = current_user.restaurants.new
    @restaurant.build_google_restaurant
    @cuisine_types = CuisineType.all
    @restaurant.cuisine_type = CuisineType.find_by(name: "other")
  end

  def update
    @restaurant = current_user.restaurants.with_google.find(params[:id])
    begin
      updater = RestaurantUpdater.new(@restaurant, restaurant_update_params)
      if updater.update
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace(
                dom_id(@restaurant, :rating),
                partial: "restaurants/rating",
                locals: { restaurant: @restaurant }
              ),
              turbo_stream.replace(
                "#{dom_id(@restaurant, :rating)}_modal",
                partial: "restaurants/rating",
                locals: { restaurant: @restaurant }
              )
            ]
          end
          format.html do
            if turbo_frame_request?
              @restaurants = current_user.restaurants.page(params[:page])
              render :index
            else
              redirect_to @restaurant
            end
          end
          format.json { render json: { status: :ok, rating: @restaurant.rating } }
        end
      else
        @cuisine_types = CuisineType.all
        flash[:alert] = @restaurant.errors.full_messages.join(", ")
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { status: :error, errors: @restaurant.errors }, status: :unprocessable_entity }
        end
      end
    rescue StandardError => e
      Rails.logger.error "Error updating restaurant #{@restaurant.id}: #{e.message}"
      @cuisine_types = CuisineType.all
      flash[:alert] ||= "Error updating the restaurant: #{e.message}"
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: :error, message: e.message }, status: :internal_server_error }
      end
      raise ActiveRecord::Rollback
    end
  end

  def update_rating
    @restaurant = current_user.restaurants.find(params[:id])
    
    if @restaurant.update(rating: params[:rating])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :rating),
            partial: "restaurants/rating",
            locals: { restaurant: @restaurant }
          )
        end
        format.html { redirect_to @restaurant }
      end
    else
      head :unprocessable_entity
    end
  end

  def create
    ActiveRecord::Base.transaction do
      begin
        @restaurant = build_restaurant
        save_restaurant(:new)
      rescue ActiveRecord::RecordNotFound => e
        @restaurant = current_user.restaurants.new(restaurant_params.except(:cuisine_type_name))
        handle_invalid_cuisine_type
      rescue StandardError => e
        Rails.logger.error "Error creating restaurant: #{e.message}"
        @restaurant&.destroy if @restaurant&.persisted?
        flash[:alert] = e.message
        handle_failed_save
      end
    end
  end

  def destroy
    @restaurant.destroy
    redirect_to restaurants_path, notice: "Restaurant was successfully removed from your list."
  end

  def add_tag
    tag_name = tag_params[:tag]
    if tag_name.present?
      @restaurant.tag_list.add(tag_name) unless @restaurant.tag_list.include?(tag_name)
      if @restaurant.save
        redirect_to restaurant_path(@restaurant), notice: "Tag added successfully."
      else
        flash[:alert] = "Failed to add tag."
        render :show
      end
    else
      redirect_to restaurant_path(@restaurant), alert: "No tag provided."
    end
  end

  def remove_tag
    tag_name = tag_params[:tag]
    if tag_name.present?
      @restaurant.tag_list.remove(tag_name)
      if @restaurant.save
        redirect_to restaurant_path(@restaurant), notice: "Tag removed successfully."
      else
        flash[:alert] = "Failed to remove tag."
        render :show
      end
    else
      redirect_to restaurant_path(@restaurant), alert: "No tag provided."
    end
  end

  private

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
    params.permit(:search, :tag, :latitude, :longitude, :order_by, :order_direction).merge(user: current_user)
  end

  def tag_params
    params.permit(:tag)
  end

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :notes, :cuisine_type_name, :cuisine_type_id,
      :rating, :price_level, :street_number, :street, :postal_code,
      :city, :state, :country, :phone_number, :url, :business_status,
      :tag_list,
      google_restaurant_attributes: [
        :google_place_id, :name, :address, :latitude, :longitude,
        :street_number, :street, :postal_code, :city, :state, :country,
        :phone_number, :url, :business_status, :google_rating,
        :google_ratings_total, :price_level, :opening_hours, :google_updated_at
      ]
    )
  end

  def build_restaurant
    cuisine_type_name = restaurant_params[:cuisine_type_name]&.downcase

    valid, result = validate_cuisine_type(cuisine_type_name)
    unless valid
      raise ActiveRecord::RecordNotFound, result
    end

    restaurant = current_user.restaurants.new(restaurant_params.except(:cuisine_type_name, :google_restaurant_attributes))
    
    if restaurant_params[:google_restaurant_attributes]
      google_restaurant = GoogleRestaurant.find_or_initialize_by_place_id(
        restaurant_params[:google_restaurant_attributes]
      )
      restaurant.google_restaurant = google_restaurant
    end

    restaurant.cuisine_type = result
    restaurant
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
    @restaurant = current_user.restaurants.find(params[:id])
  end

  def save_restaurant(render_action)
    if @restaurant.persisted? || @restaurant.save
      if params[:restaurant][:images].present?
        begin
          result = ImageProcessorService.new(@restaurant, params[:restaurant][:images]).process
          unless result.success?
            flash[:alert] = "Error updating the restaurant: Image processing failed"
            @cuisine_types = CuisineType.all
            if render_action == :edit
              raise ActiveRecord::Rollback
            else
              raise StandardError, "Image processing failed"
            end
          end
          redirect_to({ action: :show, id: @restaurant.id }, notice: "Restaurant was successfully #{render_action == :new ? 'created' : 'updated'}")
        rescue StandardError => e
          Rails.logger.error "Image processing failed: #{e.message}"
          @restaurant.destroy if render_action == :new
          if render_action == :edit
            raise ActiveRecord::Rollback
          else
            raise # Re-raise the error to be handled by the parent action
          end
        end
      else
        redirect_to({ action: :show, id: @restaurant.id }, notice: "Restaurant was successfully #{render_action == :new ? 'created' : 'updated'}")
      end
    else
      Rails.logger.error "Restaurant save failed: #{@restaurant.errors.full_messages}"
      flash.now[:alert] = "Failed to save restaurant"
      @cuisine_types = CuisineType.all
      render render_action, status: :unprocessable_entity
    end
  end
end
