class RestaurantSerializer
  include Alba::Resource

  attributes :id, :notes, :created_at, :updated_at

  attribute :name do |restaurant|
    restaurant.combined_name
  end

  attribute :address do |restaurant|
    restaurant.combined_address
  end

  attribute :street do |restaurant|
    restaurant.combined_street
  end

  attribute :street_number do |restaurant|
    restaurant.combined_street_number
  end

  attribute :city do |restaurant|
    restaurant.combined_city
  end

  attribute :state do |restaurant|
    restaurant.combined_state
  end

  attribute :country do |restaurant|
    restaurant.combined_country
  end

  attribute :postal_code do |restaurant|
    restaurant.combined_postal_code
  end

  attribute :phone_number do |restaurant|
    restaurant.combined_phone_number
  end

  attribute :url do |restaurant|
    restaurant.combined_url
  end

  attribute :price_level do |restaurant|
    restaurant.price_level
  end

  attribute :rating do |restaurant|
    restaurant.rating
  end

  attribute :business_status do |restaurant|
    restaurant.combined_business_status
  end

  attribute :google_place_id do |restaurant|
    restaurant.google_restaurant&.google_place_id
  end

  attribute :latitude do |restaurant|
    restaurant.combined_latitude&.to_f
  end

  attribute :longitude do |restaurant|
    restaurant.combined_longitude&.to_f
  end

  attribute :distance do |restaurant|
    if @params[:user_location]
      restaurant.distance_to(@params[:user_location][0], @params[:user_location][1])
    end
  end

  attribute :tags do |object|
    object.tag_list
  end

  attribute :visit_count do |restaurant|
    restaurant.visit_count
  end

  attribute :favorite do |restaurant|
    restaurant.favorite
  end

  attribute :images do |restaurant|
    restaurant.images.map do |image|
      {
        id: image.id,
        url: Rails.application.routes.url_helpers.rails_blob_url(image.file, only_path: true)
      }
    end
  end

end
