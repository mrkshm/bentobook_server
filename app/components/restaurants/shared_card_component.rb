# frozen_string_literal: true

module Restaurants
  class SharedCardComponent < ApplicationComponent
    include HeroiconHelper
    def initialize(restaurant:, current_user:, list:)
      @restaurant = restaurant
      @current_user = current_user
      @list = list
      @organization = list.organization
      @already_imported = RestaurantCopy.exists?(
        organization_id: @organization.id,
        restaurant: restaurant
      )
    end

    private

    attr_reader :restaurant, :current_user, :list, :already_imported, :organization

    def copied_restaurant
      @copied_restaurant ||= RestaurantCopy.find_by(
        organization_id: organization.id,
        restaurant: restaurant
      )&.copied_restaurant
    end

    def formatted_address
      [
        "#{restaurant.street_number} #{restaurant.street}",
        [ restaurant.postal_code, restaurant.city ].compact.join(" "),
        restaurant.state,
        restaurant.country
      ].compact.reject(&:empty?).join(", ")
    end

    def visit_count
      restaurant.visits.where(organization_id: organization.id).count
    end
  end
end
