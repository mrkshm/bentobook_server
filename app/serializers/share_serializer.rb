class ShareSerializer < BaseSerializer
  attributes :status, :permission, :reshareable, :created_at, :updated_at

  attribute :creator do
    {
      id: object.creator_id,
      email: object.creator.email,
      name: object.creator.profile.display_name
    }
  end

  attribute :recipient do
    {
      id: object.recipient_id,
      email: object.recipient.email,
      name: object.recipient.profile.display_name
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
