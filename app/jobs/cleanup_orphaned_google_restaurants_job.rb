class CleanupOrphanedGoogleRestaurantsJob < ApplicationJob
  queue_as :default

  def perform
    GoogleRestaurant
      .left_joins(:restaurants)
      .where(restaurants: { id: nil })
      .where("google_restaurants.created_at < ?", 1.week.ago)
      .delete_all
  end
end
