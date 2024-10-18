class RestaurantsController < ApplicationController
    include RestaurantManagement
    include Pagy::Backend
  
    before_action :authenticate_user!
    before_action :set_restaurant, only: [:show, :edit, :update, :destroy, :add_tag, :remove_tag]
  
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
    end
  
    def edit
      @restaurant = current_user.restaurants.with_google.includes(:images).find(params[:id])
      @cuisine_types = CuisineType.all
    end
    
    def new
      @restaurant = current_user.restaurants.new
      @restaurant.build_google_restaurant
      @cuisine_types = CuisineType.all
    end
  
    def update
      @restaurant = current_user.restaurants.with_google.find(params[:id])
      
      Rails.logger.info "Updating restaurant #{@restaurant.id} with params: #{restaurant_update_params.inspect}"
      
      updater = RestaurantUpdater.new(@restaurant, restaurant_update_params)

      if updater.update
        Rails.logger.info "Restaurant #{@restaurant.id} updated successfully"
        redirect_to restaurant_path(@restaurant), notice: 'Restaurant was successfully updated.'
      else
        Rails.logger.error "Failed to update restaurant #{@restaurant.id}: #{@restaurant.errors.full_messages}"
        render :edit, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Error updating restaurant #{@restaurant.id}: #{e.message}"
      flash.now[:alert] = "Error updating the restaurant: #{e.message}"
      render :edit, status: :unprocessable_entity
    end
  
    def create
      ActiveRecord::Base.transaction do
        @restaurant = current_user.restaurants.new(restaurant_params.except(:google_place_id))
        @restaurant.cuisine_type = CuisineType.find_or_create_by(name: params[:restaurant][:cuisine_type])
        
        @google_restaurant = GoogleRestaurant.find_or_create_by!(google_place_id: params[:restaurant][:google_place_id]) do |gr|
          gr.name = @restaurant.name
          gr.address = @restaurant.address
          gr.city = params[:restaurant][:city]
          gr.latitude = params[:restaurant][:latitude]
          gr.longitude = params[:restaurant][:longitude]
        end

        @restaurant.google_restaurant = @google_restaurant

        if @restaurant.save
          redirect_to({ action: :show, id: @restaurant.id }, notice: 'Restaurant was successfully created.')
        else
          Rails.logger.error "Restaurant save failed: #{@restaurant.errors.full_messages}"
          render :new, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create restaurant: #{e.message}"
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end
  
    def destroy
      @restaurant.destroy
      redirect_to restaurants_path, notice: 'Restaurant was successfully removed from your list.'
    end
  
    def add_tag
      tag_name = tag_params[:tag]
      if tag_name.present?
        @restaurant.tag_list.add(tag_name) unless @restaurant.tag_list.include?(tag_name)
        if @restaurant.save
          redirect_to restaurant_path(@restaurant), notice: 'Tag added successfully.'
        else
          flash.now[:alert] = 'Failed to add tag.'
          render :show
        end
      else
        redirect_to restaurant_path(@restaurant), alert: 'No tag provided.'
      end
    end
  
    def remove_tag
      tag_name = tag_params[:tag]
      if tag_name.present?
        @restaurant.tag_list.remove(tag_name)
        if @restaurant.save
          redirect_to restaurant_path(@restaurant), notice: 'Tag removed successfully.'
        else
          flash.now[:alert] = 'Failed to remove tag.'
          render :show
        end
      else
        redirect_to restaurant_path(@restaurant), alert: 'No tag provided.'
      end
    end
  
    private
  
    def parse_order_params
      order_field = params[:order_by] || RestaurantQuery::DEFAULT_ORDER[:field]
      order_direction = params[:order_direction] || RestaurantQuery::DEFAULT_ORDER[:direction]

      unless RestaurantQuery::ALLOWED_ORDER_FIELDS.include?(order_field)
        flash.now[:alert] = 'Invalid order_by parameter. Using default sorting.'
        order_field = RestaurantQuery::DEFAULT_ORDER[:field]
      end

      unless valid_order_direction?(order_direction)
        flash.now[:alert] = 'Invalid order_direction parameter. Using default direction.'
        order_direction = RestaurantQuery::DEFAULT_ORDER[:direction]
      end

      { order_by: order_field, order_direction: order_direction }
    end
  
    def valid_order_direction?(direction)
      ['asc', 'desc'].include?(direction.to_s.downcase)
    end
  
    def search_params
      params.permit(:search, :tag, :latitude, :longitude).merge(user: current_user)
    end
  
    def tag_params
      params.permit(:tag)
    end
  
    def restaurant_params
      params.require(:restaurant).permit(:name, :address, :google_place_id)
    end
  
    def build_restaurant
      restaurant = current_user.restaurants.new(restaurant_params.except(:cuisine_type))
      cuisine_type_name = restaurant_params[:cuisine_type]
      if cuisine_type_name.present?
        restaurant.cuisine_type = CuisineType.find_or_create_by(name: cuisine_type_name)
      end
      restaurant
    end
  
    def restaurant_update_params
      params.require(:restaurant).permit(
        :name, :address, :notes, :cuisine_type_id, :cuisine_type_name, :rating, :price_level,
        :street_number, :street, :postal_code, :city, :state, :country,
        :phone_number, :url, :business_status, :tag_list,
        images: []
      )
    end
  
  end
