class List < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :list_restaurants, dependent: :destroy
  has_many :restaurants, through: :list_restaurants
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :shared_users, through: :shares, source: :recipient

  validates :name, presence: true
  validates :organization, presence: true
  validates :creator, presence: true

  enum :visibility, { personal: 0, discoverable: 1 }

  default_scope { order(position: :asc) }

  scope :personal_lists, -> { where(visibility: :personal) }
  scope :discoverable_lists, -> { where(visibility: :discoverable) }
  scope :shared_with, ->(user) {
    joins(:shares).where(shares: { recipient: user, status: :accepted })
  }

  scope :containing_restaurant, ->(restaurant) {
    joins(:list_restaurants)
      .where("list_restaurants.restaurant_id = :id
             OR list_restaurants.restaurant_id = :original_id
             OR list_restaurants.restaurant_id IN (
               SELECT id FROM restaurants
               WHERE original_restaurant_id = :id
             )",
             id: restaurant.id,
             original_id: restaurant.original_restaurant_id)
  }

  scope :accessible_by, ->(user) {
    where(organization: user.organization)
      .or(
        joins(:shares)
          .where(shares: { recipient: user, status: :accepted })
      )
  }

  def viewable_by?(user)
    organization == user.organization || shares.accepted.exists?(recipient: user)
  end

  def editable_by?(user)
    # Only organization members can edit lists
    organization == user.organization
  end

  def deletable_by?(user)
    return false unless user
    organization == user.organization
  end
end
