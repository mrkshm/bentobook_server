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
end
