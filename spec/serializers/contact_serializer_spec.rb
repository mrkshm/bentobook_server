# == Schema Information
#
# Table name: contacts
#
#  id              :bigint           not null, primary key
#  city            :string
#  country         :string
#  email           :string
#  name            :string
#  notes           :text
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_contacts_on_name_and_organization_id  (name,organization_id) UNIQUE
#  index_contacts_on_organization_id           (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe ContactSerializer do
  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }
  let(:contact) { create(:contact, organization: organization) }
  let(:restaurant) { create(:restaurant, organization: organization) }

  before do
    Rails.application.routes.default_url_options[:host] = 'example.com'
  end

  describe '.render_collection' do
    let(:contacts) { create_list(:contact, 3, organization: organization) }

    context 'without pagination' do
      subject(:rendered_json) { ContactSerializer.render_collection(contacts) }

      it 'follows the collection format' do
        expect(rendered_json).to include(
          status: 'success',
          data: be_an(Array),
          meta: include(:timestamp)
        )
      end

      it 'formats each resource correctly' do
        expect(rendered_json[:data].first).to include(
          id: contacts.first.id.to_s,
          type: 'contact',
          attributes: include(
            'name',
            'email'
          )
        )
      end

      it 'includes meta information without pagination' do
        expect(rendered_json[:meta]).to include(:timestamp)
        expect(rendered_json[:meta][:pagination]).to be_nil
      end

      it 'includes the correct number of resources' do
        expect(rendered_json[:data].length).to eq(3)
      end
    end

    context 'with pagination' do
      before do
        Pagy::DEFAULT[:items] = 2 # Set items per page for test
      end

      let(:pagy) { instance_double(Pagy, page: 1, pages: 2, count: 3) }
      subject(:rendered_json) { ContactSerializer.render_collection(contacts, pagy: pagy) }

      it 'includes pagination information' do
        expect(rendered_json[:meta][:pagination]).to include(
          current_page: 1,
          total_pages: 2,
          total_count: 3,
          per_page: Pagy::DEFAULT[:items]
        )
      end
    end

    context 'with additional meta information' do
      let(:additional_meta) { { custom_key: 'custom_value' } }
      subject(:rendered_json) { ContactSerializer.render_collection(contacts, meta: additional_meta) }

      it 'merges additional meta information' do
        expect(rendered_json[:meta]).to include(
          timestamp: be_present,
          custom_key: 'custom_value'
        )
      end
    end
  end

  describe '.render_success' do
    subject(:rendered_json) { ContactSerializer.render_success(contact) }

    it 'follows the JSON API format' do
      expect(rendered_json).to have_key(:data)
      expect(rendered_json[:data]).to have_key(:attributes)
    end

    it 'includes the correct attributes' do
      expect(rendered_json[:data][:attributes]).to include(
        'name',
        'email',
        'city',
        'country',
        'phone',
        'notes',
        'created_at',
        'updated_at',
        'visits_count'
      )
    end

    context 'with avatar' do
      before do
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        # Use the new avatar handling with medium and thumbnail variants
        result = PreprocessAvatarService.call(
          fixture_file_upload(file_path, 'image/jpeg')
        )
        contact.avatar_medium.attach(result[:variants][:medium])
        contact.avatar_thumbnail.attach(result[:variants][:thumbnail])
      end

      it 'includes avatar urls' do
        expect(rendered_json[:data][:attributes]['avatar_urls']).to include(
          'medium',
          'thumbnail'
        )
      end
    end

    context 'with visits' do
      let!(:visit) do
        create(:visit,
          organization: organization,
          restaurant: restaurant,
          contacts: [ contact ],
          date: Date.current,
          title: 'Birthday dinner',
          notes: 'Great time',
          rating: 4
        )
      end

      before do
        # Force loading of visits association
        contact.visits.reload
      end

      it 'includes visits when loaded' do
        visits = rendered_json[:data][:attributes]['visits']
        expect(visits).to be_present
        expect(visits.first).to include(
          'id' => visit.id,
          'date' => visit.date.as_json,
          'title' => 'Birthday dinner',
          'notes' => 'Great time',
          'rating' => 4
        )
      end

      it 'includes restaurant information in visits' do
        visit_restaurant = rendered_json[:data][:attributes]['visits'].first['restaurant']
        expect(visit_restaurant).to include(
          'id' => restaurant.id,
          'name' => restaurant.combined_name,
          'cuisine_type' => restaurant.cuisine_type&.name
        )
        expect(visit_restaurant['location']).to include(
          'address' => restaurant.address,
          'latitude' => restaurant.latitude&.to_f,
          'longitude' => restaurant.longitude&.to_f
        )
      end

      context 'with visit images' do
        before do
          image = visit.images.new
          file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
          image.file.attach(io: File.open(file_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
          image.save!
        end

        it 'includes visit images with variants' do
          visit_images = rendered_json[:data][:attributes]['visits'].first['images']
          expect(visit_images.first).to include(
            'urls' => include(
              'thumbnail',
              'small',
              'medium'
            )
          )
        end

        it 'skips images without attached files' do
          # Create an image object but don't attach a file
          image = visit.images.new
          image.save(validate: false)

          visit_images = rendered_json[:data][:attributes]['visits'].first['images']
          expect(visit_images.length).to eq(1) # Should only include the valid image
        end
      end
    end
  end
end
