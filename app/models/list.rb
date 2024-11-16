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

  def viewable_by?(user)
    owner == user || shares.accepted.exists?(recipient: user)
  end

  def editable_by?(user)
    owner == user || shares.accepted.edit.exists?(recipient: user)
  end
end
