# == Schema Information
#
# Table name: shares
#
#  id                     :bigint           not null, primary key
#  permission             :integer          default("view")
#  reshareable            :boolean          default(TRUE), not null
#  shareable_type         :string           not null
#  status                 :integer          default("pending")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  creator_id             :bigint           not null
#  shareable_id           :bigint           not null
#  source_organization_id :bigint           not null
#  target_organization_id :bigint           not null
#
# Indexes
#
#  index_shares_on_creator_id                   (creator_id)
#  index_shares_on_organizations_and_shareable  (source_organization_id,target_organization_id,shareable_type,shareable_id)
#  index_shares_on_shareable                    (shareable_type,shareable_id)
#  index_shares_on_source_organization_id       (source_organization_id)
#  index_shares_on_target_organization_id       (target_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (source_organization_id => organizations.id)
#  fk_rails_...  (target_organization_id => organizations.id)
#
class ShareSerializer < BaseSerializer
  attributes :status, :permission, :reshareable, :created_at, :updated_at

  attribute :creator do |share|
    {
      id: share.creator_id,
      email: share.creator.email,
      name: share.creator.display_name
    }
  end

  attribute :source_organization do |share|
    {
      id: share.source_organization_id
    }
  end

  attribute :target_organization do |share|
    {
      id: share.target_organization_id
    }
  end

  attribute :shareable do |share|
    case share.shareable_type
    when "List"
      {
        id: share.shareable_id,
        type: share.shareable_type,
        name: share.shareable.name,
        description: share.shareable.description,
        restaurant_count: share.shareable.restaurants.count
      }
    else
      {
        id: share.shareable_id,
        type: share.shareable_type
      }
    end
  end
end
