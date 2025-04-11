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
