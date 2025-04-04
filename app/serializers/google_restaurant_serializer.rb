class GoogleRestaurantSerializer < BaseSerializer
  def self.render_success(resource, meta: {})
    {
      data: render(resource),
      meta: meta
    }
  end

  def self.render(resource)
    {
      id: resource.id,
      type: "google_restaurant",
      attributes: {
        name: resource.name,
        google_place_id: resource.google_place_id,
        address: resource.address,
        city: resource.city,
        latitude: resource.latitude,
        longitude: resource.longitude,
        google_rating: resource.google_rating,
        street: resource.street,
        postal_code: resource.postal_code,
        country: resource.country,
        phone: resource.phone,
        website: resource.website,
        created_at: resource.created_at,
        updated_at: resource.updated_at
      }
    }
  end
end
