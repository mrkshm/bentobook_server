# frozen_string_literal: true

class SharedRestaurantCardComponent < ApplicationComponent
  def initialize(restaurant:, current_user:, list:)
    @restaurant = restaurant
    @current_user = current_user
    @list = list
    @already_imported = RestaurantCopy.exists?(
      user: current_user,
      restaurant: restaurant
    )
  end

  private

  attr_reader :restaurant, :current_user, :list, :already_imported

  def formatted_address
    [
      "#{restaurant.street_number} #{restaurant.street}",
      [restaurant.postal_code, restaurant.city].compact.join(' '),
      restaurant.state,
      restaurant.country
    ].compact.reject(&:empty?).join(', ')
  end

  def visit_count
    restaurant.visits.where(user: current_user).count
  end
end