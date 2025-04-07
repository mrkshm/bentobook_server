class List < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :list_restaurants, dependent: :destroy
  has_many :restaurants, through: :list_restaurants
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :shared_organizations, through: :shares, source: :target_organization

  validates :name, presence: true
  validates :organization, presence: true
  validates :creator, presence: true

  enum :visibility, { personal: 0, discoverable: 1 }

  default_scope { order(position: :asc) }

  scope :personal_lists, -> { where(visibility: :personal) }
  scope :discoverable_lists, -> { where(visibility: :discoverable) }
  
  # Find lists shared with a specific organization
  scope :shared_with_organization, ->(organization) {
    joins(:shares).where(shares: { target_organization: organization, status: :accepted })
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

  # Find all lists accessible to a user based on their organization memberships
  # This includes:
  # 1. Lists from organizations the user belongs to
  # 2. Lists shared with organizations the user belongs to
  scope :accessible_by, ->(user) {
    user_org_ids = user.organizations.select(:id)
    
    left_joins(:shares)
      .where(
        "lists.organization_id IN (?) OR 
        (shares.target_organization_id IN (?) AND shares.status = ?)",
        user_org_ids,
        user_org_ids,
        Share.statuses[:accepted]
      )
      .distinct
  }

  def viewable_by?(user)
    return false unless user
    
    # User can view if they belong to the list's organization
    return true if user.organizations.exists?(id: organization.id)
    
    # User can view if the list is shared with any of their organizations
    user_org_ids = user.organizations.pluck(:id)
    shares.accepted.where(target_organization_id: user_org_ids).exists?
  end

  def editable_by?(user)
    return false unless user
    
    # Only members of the list's organization can edit it
    user.organizations.exists?(id: organization.id)
  end

  def deletable_by?(user)
    return false unless user
    
    # Only members of the list's organization can delete it
    user.organizations.exists?(id: organization.id)
  end
end
