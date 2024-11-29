require 'rails_helper'

RSpec.describe RestaurantSerializer do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:serializer) { RestaurantSerializer.new(restaurant) }

  before do
    Rails.application.routes.default_url_options[:host] = 'example.com'
  end

  describe '#serialize' do
    subject(:serialized_restaurant) { JSON.parse(serializer.serialize) }

    it 'includes the correct top-level keys' do
      expected_keys = %w[
        id notes favorite created_at updated_at name cuisine_type price_level rating
        business_status location contact_info google_place_id distance tags
        visit_count images
      ]
      expect(serialized_restaurant.keys).to match_array(expected_keys)
    end

    it 'has the correct basic attributes' do
      expect(serialized_restaurant['notes']).to eq(restaurant.notes)
      expect(serialized_restaurant['favorite']).to eq(restaurant.favorite)
      expect(Time.parse(serialized_restaurant['created_at'])).to be_within(1.second).of(restaurant.created_at)
      expect(Time.parse(serialized_restaurant['updated_at'])).to be_within(1.second).of(restaurant.updated_at)
    end

    it 'has the correct core restaurant details' do
      expect(serialized_restaurant['name']).to eq(restaurant.combined_name)
      expect(serialized_restaurant['cuisine_type']).to eq(restaurant.cuisine_type&.name)
      expect(serialized_restaurant['price_level']).to eq(restaurant.price_level)
      expect(serialized_restaurant['rating']).to eq(restaurant.rating)
      expect(serialized_restaurant['business_status']).to eq(restaurant.combined_business_status)
    end

    it 'has the correct location details' do
      location = serialized_restaurant['location']
      expect(location['address']).to eq(restaurant.combined_address)
      expect(location['street']).to eq(restaurant.combined_street)
      expect(location['street_number']).to eq(restaurant.combined_street_number)
      expect(location['city']).to eq(restaurant.combined_city)
      expect(location['state']).to eq(restaurant.combined_state)
      expect(location['country']).to eq(restaurant.combined_country)
      expect(location['postal_code']).to eq(restaurant.combined_postal_code)
      expect(location['latitude']).to eq(restaurant.combined_latitude&.to_f)
      expect(location['longitude']).to eq(restaurant.combined_longitude&.to_f)
    end

    it 'has the correct contact information' do
      contact_info = serialized_restaurant['contact_info']
      expect(contact_info['phone_number']).to eq(restaurant.combined_phone_number)
      expect(contact_info['url']).to eq(restaurant.combined_url)
    end

    it 'has the correct google place id' do
      expect(serialized_restaurant['google_place_id']).to eq(restaurant.google_restaurant&.google_place_id)
    end

    it 'has the correct tags' do
      expect(serialized_restaurant['tags']).to eq(restaurant.tag_list)
    end

    it 'has the correct visit count' do
      expect(serialized_restaurant['visit_count']).to eq(restaurant.visit_count)
    end

    context 'when user_location is provided' do
      let(:user_location) { [ 40.7128, -74.0060 ] }
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
      before do
        image = restaurant.images.new
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        image.file.attach(
          io: File.open(file_path),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
        image.save!
      end

      it 'includes image information with all sizes' do
        expect(serialized_restaurant['images']).to be_an(Array)
        expect(serialized_restaurant['images'].length).to eq(1)

        image_data = serialized_restaurant['images'].first
        expect(image_data['id']).to be_present
        expect(image_data['urls']).to include(
          'thumbnail',
          'small',
          'medium',
          'large',
          'original'
        )

        # Verify all URLs are properly formed
        image_data['urls'].values.each do |url|
          expect(url).to start_with('http://example.com/')
        end
      end

      it 'skips images without attached files' do
        # Create an image object but don't attach a file
        image = restaurant.images.new
        image.save(validate: false) # Skip validation to create an invalid image

        expect(serialized_restaurant['images'].length).to eq(1) # Should only include the valid image
      end
    end
  end

  describe '.render_success' do
    subject(:rendered_json) { RestaurantSerializer.render_success(restaurant) }

    it 'follows the BaseSerializer format' do
      expect(rendered_json[:status]).to eq('success')
      expect(rendered_json[:data]).to include(
        id: restaurant.id.to_s,
        type: 'restaurant'
      )
      expect(rendered_json[:data][:attributes]).to be_present
      expect(rendered_json[:meta]).to include(:timestamp)
    end
  end

  describe '.render_collection' do
    let(:restaurants) { create_list(:restaurant, 2, user: user) }
    let(:pagy) { instance_double(Pagy, page: 1, pages: 1, count: 2, vars: { items: 10 }) }

    subject(:rendered_json) { RestaurantSerializer.render_collection(restaurants, pagy: pagy) }

    it 'follows the BaseSerializer format for collections' do
      expect(rendered_json[:status]).to eq('success')
      expect(rendered_json[:data]).to be_an(Array)
      expect(rendered_json[:data].length).to eq(2)
      expect(rendered_json[:meta]).to include(:timestamp, :pagination)
      expect(rendered_json[:meta][:pagination]).to include(
        :current_page,
        :per_page,
        :total_pages,
        :total_count
      )
    end
  end
end
