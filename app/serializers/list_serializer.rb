class ListSerializer < BaseSerializer
  attributes :name, :description, :visibility, :premium, :position, :created_at, :updated_at

  attribute :restaurant_count do
    object.restaurants.count
  end

  attribute :restaurants, if: :include_restaurants? do
    object.restaurants.map do |r|
      {
        id: r.id,
        name: r.name,
        address: r.address,
        postal_code: r.postal_code,
        city: r.city,
        state: r.state,
        country: r.country,
        rating: r.rating,
        price_level: r.price_level
      }
    end
  end

  attribute :shared_with do
    object.shares.accepted.map do |share|
      {
        user_id: share.recipient_id,
        permission: share.permission
      }
    end
  end

  private

  def include_restaurants?
    @options[:include_restaurants]
  end
end
