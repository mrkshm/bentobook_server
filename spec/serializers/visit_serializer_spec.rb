require 'rails_helper'

RSpec.describe VisitSerializer do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:restaurant) { create(:restaurant, organization: organization) }
  let(:visit) do
    create(:visit,
      organization: organization,
      restaurant: restaurant,
      price_paid_cents: 1000,
      price_paid_currency: 'USD'
    )
  end

  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    Rails.application.routes.default_url_options[:host] = 'example.com'
  end

  describe '.render_success' do
    subject(:rendered_json) { VisitSerializer.render_success(visit) }

    it 'follows the JSON API format' do
      expect(rendered_json).to have_key(:data)
      expect(rendered_json[:data]).to have_key(:attributes)
    end

    it 'includes the correct attributes' do
      expect(rendered_json[:data][:attributes]).to include(
        'date',
        'title',
        'notes',
        'rating',
        'created_at',
        'updated_at',
        'restaurant'
      )
    end

    it 'includes correct restaurant information' do
      restaurant_data = rendered_json[:data][:attributes]['restaurant']
      expect(restaurant_data).to include(
        'id' => restaurant.id,
        'name' => restaurant.name,
        'cuisine_type' => restaurant.cuisine_type&.name
      )
      expect(restaurant_data['location']).to include(
        'address' => restaurant.address,
        'latitude' => restaurant.latitude&.to_f,
        'longitude' => restaurant.longitude&.to_f
      )
    end

    it 'formats price_paid correctly' do
      expect(rendered_json[:data][:attributes]["price_paid"]).to eq({
        'amount' => '10.00',
        'currency' => 'USD'
      })
    end

    context 'with images' do
      before do
        image = visit.images.new
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        image.file.attach(io: File.open(file_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
        image.save!
      end

      it 'includes images with variants' do
        images = rendered_json[:data][:attributes]["images"]
        expect(images.first).to include(
          'urls' => include(
            'thumbnail',
            'small',
            'medium',
            'large',
            'original'
          )
        )
      end

      it 'skips images without attached files' do
        # Create an image object but don't attach a file
        image = visit.images.new
        image.save(validate: false) # Skip validation to create an invalid image

        images = rendered_json[:data][:attributes]["images"]
        expect(images.length).to eq(1) # Should only include the valid image from before
      end
    end

    context 'with associated contacts' do
      let(:contact) { create(:contact, organization: organization, name: 'John Doe') }

      before do
        visit.contacts << contact
        
        # Add avatar variants
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        result = PreprocessAvatarService.call(
          fixture_file_upload(file_path, 'image/jpeg')
        )
        contact.avatar_medium.attach(result[:variants][:medium])
        contact.avatar_thumbnail.attach(result[:variants][:thumbnail])
      end

      it 'includes contacts in the response' do
        contacts = rendered_json[:data][:attributes]['contacts']
        expect(contacts).to be_present
        expect(contacts.first).to include(
          'id' => contact.id,
          'name' => 'John Doe',
          'email' => contact.email,
          'phone' => contact.phone,
          'notes' => contact.notes
        )
      end
      
      it 'includes avatar urls for contacts' do
        contacts = rendered_json[:data][:attributes]['contacts']
        expect(contacts.first['avatar_urls']).to include(
          'medium',
          'thumbnail'
        )
      end
    end

    context 'without contacts' do
      it 'returns an empty array for contacts' do
        expect(rendered_json[:data][:attributes]['contacts']).to eq([])
      end
    end

    context 'without price' do
      let(:visit) { create(:visit, organization: organization, restaurant: restaurant, price_paid_cents: nil, price_paid_currency: nil) }

      it 'returns nil for price_paid' do
        expect(rendered_json[:data][:attributes]["price_paid"]).to be_nil
      end
    end

    context 'without rating' do
      let(:visit) { create(:visit, organization: organization, restaurant: restaurant, rating: nil) }

      it 'allows nil rating' do
        expect(rendered_json[:data][:attributes]["rating"]).to be_nil
      end
    end
  end
end
