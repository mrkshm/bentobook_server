module Sortable
  extend ActiveSupport::Concern

  private

  # Returns the current sort column, defaulting to 'name' if invalid
  def sort_column
    params[:field].presence_in(%w[name rating price_level distance created_at updated_at]) || "name"
  end

  # Returns the current sort direction, defaulting to 'asc' if invalid
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Applies sorting to the given relation
  def apply_sort(relation, default_sort: "name", default_direction: "asc")
    column     = sort_column.presence || default_sort
    direction  = sort_direction.presence || default_direction

    safe_column    = column.to_s.downcase
    safe_direction = direction.downcase == "desc" ? "DESC" : "ASC"

    if safe_column == "distance"
      return apply_distance_sort(relation, safe_direction)
    end

    relation.reorder(safe_column => safe_direction)
  end

  # Orders a relation by distance (in km) from the given lat/lng params using the Haversine formula.
  # Requires params[:latitude]/[:lat] and params[:longitude]/[:lng]
  def apply_distance_sort(relation, direction)
    lat = params[:latitude] || params[:lat]
    lng = params[:longitude] || params[:lng]
    return relation unless lat.present? && lng.present?

    # Haversine in SQL (PostgreSQL)
    haversine_sql = ActiveRecord::Base.send(:sanitize_sql_array, [
      "(6371 * acos( cos(radians(?)) * cos(radians(restaurants.latitude)) * cos(radians(restaurants.longitude) - radians(?)) + sin(radians(?)) * sin(radians(restaurants.latitude)) ))",
      lat, lng, lat
    ])

    relation_with_distance = relation
      .where.not(latitude: nil, longitude: nil)
      .select("restaurants.*, (#{haversine_sql})::double precision AS distance_km")
      .reorder(Arel.sql("#{haversine_sql} #{direction}, restaurants.id"))

    # Optional lightweight debug (won't crash if alias not exposed)
    Rails.logger.debug "Distance sort applied (origin: #{lat},#{lng})" if Rails.logger

    relation_with_distance
  end
end
