class ShareSerializer < BaseSerializer
  attributes :status, :permission, :reshareable, :created_at, :updated_at

  attribute :creator do
    {
      id: object.creator_id,
      email: object.creator.email,
      name: object.creator.profile.display_name
    }
  end

  attribute :source_organization do
    {
      id: object.source_organization_id,
      name: object.source_organization.name
    }
  end

  attribute :target_organization do
    {
      id: object.target_organization_id,
      name: object.target_organization.name
    }
  end

  # Keep the recipient attribute for backward compatibility
  # This will be removed in a future version
  attribute :recipient, if: -> { object.respond_to?(:recipient_id) && object.recipient_id.present? } do
    {
      id: object.recipient_id,
      email: object.recipient&.email,
      name: object.recipient&.profile&.display_name
    }
  end

  attribute :shareable do
    case object.shareable_type
    when "List"
      {
        id: object.shareable_id,
        type: object.shareable_type,
        name: object.shareable.name,
        description: object.shareable.description,
        restaurant_count: object.shareable.restaurants.count
      }
    else
      {
        id: object.shareable_id,
        type: object.shareable_type
      }
    end
  end
end
