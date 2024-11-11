class List < ApplicationRecord
  belongs_to :owner, polymorphic: true
  
  has_many :list_restaurants, class_name: 'ListRestaurant', dependent: :destroy
  has_many :restaurants, through: :list_restaurants
  
  validates :name, presence: true
  
  enum :visibility, { personal: 0, restricted: 1, discoverable: 2 }
  
  default_scope { order(position: :asc) }
  
  scope :discoverable_lists, -> { where(visibility: :discoverable) }
  scope :shared_with, ->(user) { 
    joins(:shares).where(shares: { recipient: user, status: :accepted }) 
  }

  def total_restaurants
    restaurants.count
  end

  def visited_percentage
    return 0 if total_restaurants.zero?
    
    visited_count = restaurants
      .joins(:visits)
      .where(visits: { user_id: owner_id })
      .distinct
      .count
    
    (visited_count.to_f / total_restaurants * 100).round
  end

  def visited_count
    restaurants
      .joins(:visits)
      .where(visits: { user_id: owner_id })
      .distinct
      .count
  end

  def last_updated_at
    [
      updated_at,
      list_restaurants.maximum(:updated_at),
      list_restaurants.joins(:restaurant)
        .maximum('restaurants.updated_at')
    ].compact.max
  end
end
