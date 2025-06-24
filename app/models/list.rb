# == Schema Information
#
# Table name: lists
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string           not null
#  position        :integer
#  premium         :boolean          default(FALSE)
#  visibility      :integer          default("personal")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :bigint           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_lists_on_creator_id       (creator_id)
#  index_lists_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
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

  # Check if a list is viewable by a user or organization
  # If passed a user, checks if the user belongs to the list's organization or any organization the list is shared with
  # If passed an organization, checks if the organization owns the list or the list is shared with it
  def viewable_by?(entity)
    return false unless entity
    
    if entity.is_a?(User)
      # User can view if they belong to the list's organization
      return true if entity.organizations.exists?(id: organization.id)
      
      # User can view if the list is shared with any of their organizations
      user_org_ids = entity.organizations.pluck(:id)
      shares.accepted.where(target_organization_id: user_org_ids).exists?
    elsif entity.is_a?(Organization)
      # Organization can view if it owns the list
      return true if entity.id == organization.id
      
      # Organization can view if the list is shared with it
      shares.accepted.where(target_organization_id: entity.id).exists?
    else
      false
    end
  end

  # Check if a list is editable by a user or organization
  # If passed a user, checks if the user belongs to the list's organization
  # If passed an organization, checks if the organization owns the list
  def editable_by?(entity)
    return false unless entity
    
    if entity.is_a?(User)
      # Only members of the list's organization can edit it
      entity.organizations.exists?(id: organization.id)
    elsif entity.is_a?(Organization)
      # Only the owning organization can edit it
      entity.id == organization.id
    else
      false
    end
  end

  # Check if a list is deletable by a user or organization
  # If passed a user, checks if the user belongs to the list's organization
  # If passed an organization, checks if the organization owns the list
  def deletable_by?(entity)
    return false unless entity
    
    if entity.is_a?(User)
      # Only members of the list's organization can delete it
      entity.organizations.exists?(id: organization.id)
    elsif entity.is_a?(Organization)
      # Only the owning organization can delete it
      entity.id == organization.id
    else
      false
    end
  end
end
