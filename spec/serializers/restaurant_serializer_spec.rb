require 'rails_helper'

RSpec.describe RestaurantSerializer do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:serializer) { RestaurantSerializer.new(restaurant) }

  describe '#serialize' do
    subject(:serialized_restaurant) { JSON.parse(serializer.serialize) }

    it 'includes the correct keys' do
      expected_keys = %w[
        id notes created_at updated_at name address street street_number city state country
        postal_code phone_number url price_level rating business_status google_place_id
        latitude longitude distance tags visit_count favorite images
      ]
      expect(serialized_restaurant.keys).to match_array(expected_keys)
    end

    it 'has the correct basic attributes' do
      expect(serialized_restaurant['id']).to eq(restaurant.id)
      expect(serialized_restaurant['notes']).to eq(restaurant.notes)
      expect(Time.parse(serialized_restaurant['created_at'])).to be_within(1.second).of(restaurant.created_at)
      expect(Time.parse(serialized_restaurant['updated_at'])).to be_within(1.second).of(restaurant.updated_at)
    end

    it 'has the correct combined attributes' do
      expect(serialized_restaurant['name']).to eq(restaurant.combined_name)
      expect(serialized_restaurant['address']).to eq(restaurant.combined_address)
      expect(serialized_restaurant['street']).to eq(restaurant.combined_street)
      expect(serialized_restaurant['street_number']).to eq(restaurant.combined_street_number)
      expect(serialized_restaurant['city']).to eq(restaurant.combined_city)
      expect(serialized_restaurant['state']).to eq(restaurant.combined_state)
      expect(serialized_restaurant['country']).to eq(restaurant.combined_country)
      expect(serialized_restaurant['postal_code']).to eq(restaurant.combined_postal_code)
      expect(serialized_restaurant['phone_number']).to eq(restaurant.combined_phone_number)
      expect(serialized_restaurant['url']).to eq(restaurant.combined_url)
      expect(serialized_restaurant['business_status']).to eq(restaurant.combined_business_status)
    end

    it 'has the correct price level and rating' do
      expect(serialized_restaurant['price_level']).to eq(restaurant.price_level)
      expect(serialized_restaurant['rating']).to eq(restaurant.rating)
    end

    it 'has the correct google place id' do
      expect(serialized_restaurant['google_place_id']).to eq(restaurant.google_restaurant&.google_place_id)
    end

    it 'has the correct latitude and longitude' do
      expect(serialized_restaurant['latitude']).to eq(restaurant.combined_latitude&.to_f)
      expect(serialized_restaurant['longitude']).to eq(restaurant.combined_longitude&.to_f)
    end

    it 'has the correct tags' do
      expect(serialized_restaurant['tags']).to eq(restaurant.tag_list)
    end

    it 'has the correct visit count' do
      expect(serialized_restaurant['visit_count']).to eq(restaurant.visit_count)
    end

    it 'has the correct favorite status' do
      expect(serialized_restaurant['favorite']).to eq(restaurant.favorite)
    end

    context 'when user_location is provided' do
      let(:user_location) { [40.7128, -74.0060] }
      let(:serializer) { RestaurantSerializer.new(restaurant, params: { user_location: user_location }) }

      it 'includes the distance' do
        expect(serialized_restaurant['distance']).to be_present
      end
    end

    context 'when user_location is not provided' do
      it 'does not include the distance' do
        expect(serialized_restaurant['distance']).to be_nil
      end
    end

    context 'when restaurant has images' do
      let(:image) { create(:image, imageable: restaurant) }

      before do
        # Ensure the image is associated with the restaurant
        restaurant.images << image
        
        # Stub the rails_blob_url helper
        allow(Rails.application.routes.url_helpers).to receive(:rails_blob_url)
          .and_return('http://example.com/image.jpg')
      end

      it 'includes image information' do
        expect(serialized_restaurant['images']).to be_an(Array)
        expect(serialized_restaurant['images'].length).to eq(1)
        expect(serialized_restaurant['images'].first).to include(
          'id' => image.id,
          'url' => 'http://example.com/image.jpg'
        )
      end
    end
  end
end
