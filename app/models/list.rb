class List < ApplicationRecord
  belongs_to :owner, polymorphic: true
  
  has_many :list_restaurants, dependent: :destroy
  has_many :restaurants, through: :list_restaurants
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :shared_users, through: :shares, source: :recipient
  
  validates :name, presence: true
  
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
    where("(lists.owner_type = 'User' AND lists.owner_id = :user_id) OR lists.id IN (
      SELECT shareable_id FROM shares 
      WHERE shares.shareable_type = 'List' 
      AND shares.recipient_id = :user_id 
      AND shares.status = :status
    )", user_id: user.id, status: Share.statuses[:accepted])
  }

  def viewable_by?(user)
    owner == user || shares.accepted.exists?(recipient: user)
  end

  def editable_by?(user)
    owner == user || shares.accepted.edit.exists?(recipient: user)
  end
end
