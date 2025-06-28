module RestaurantScoped
  extend ActiveSupport::Concern

  private

  def set_restaurant
    @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Restaurant not found" }, status: :not_found
    false
  end
end
