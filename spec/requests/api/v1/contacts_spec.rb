require 'rails_helper'

RSpec.describe 'Api::V1::Contacts', type: :request do
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  before(:all) do
    Pagy::DEFAULT[:items] ||= 10
  end

  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }  # Use the user's default organization
  let(:headers) { sign_in_with_token(user) }
  let(:test_image) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg',
      true
    )
  end

  let(:contact_attributes) do
    {
      name: 'John Doe',
      email: 'john@example.com',
      city: 'San Francisco',
      country: 'USA',
      phone: '+1234567890',
      notes: 'Test contact'
    }
  end

  before(:each) do
    # Set up current organization
    Current.organization = organization
  end

  after(:each) do
    # Clean up any processed images
    ActiveStorage::Blob.unattached.find_each(&:purge)
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage/*"])
    Current.organization = nil
  end

  describe 'GET /api/v1/contacts' do
    context 'with no contacts' do
      it 'returns an empty list' do
        get '/api/v1/contacts', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_empty
        expect(json_response['meta']).to include('timestamp')
        expect(json_response['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 0,
          'per_page' => 10
        )
      end
    end

    context 'with unauthorized access' do
      it 'returns unauthorized without valid token' do
        get '/api/v1/contacts'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns forbidden for contact from another organization' do
        other_org = create(:organization)
        other_contact = create(:contact, organization: other_org)
        
        get "/api/v1/contacts/#{other_contact.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with multiple contacts' do
      let!(:contact1) { create(:contact, organization: organization, name: 'Alice Anderson', email: 'alice@example.com', created_at: 2.days.ago) }
      let!(:contact2) { create(:contact, organization: organization, name: 'Bob Brown', email: 'bob@example.com', created_at: 1.day.ago) }
      let!(:contact3) { create(:contact, organization: organization, name: 'Charlie Cooper', email: 'charlie@example.com', created_at: Time.current) }

      before do
        # Create some visits
        create(:visit, organization: organization, contacts: [ contact1 ])
        create_list(:visit, 2, organization: organization, contacts: [ contact2 ])
        create_list(:visit, 3, organization: organization, contacts: [ contact3 ])
      end

      it 'returns contacts ordered by created_at desc by default' do
        get '/api/v1/contacts', headers: headers

        contact_ids = json_response['data'].map { |c| c['id'].to_i }
        expect(contact_ids).to eq([ contact3.id, contact2.id, contact1.id ])
      end

      context 'with search parameter' do
        it 'returns matching contacts' do
          get '/api/v1/contacts', params: { search: 'bob' }, headers: headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Bob Brown')
        end

        it 'returns empty array for no matches' do
          get '/api/v1/contacts', params: { search: 'xyz' }, headers: headers

          expect(json_response['data']).to be_empty
        end
      end

      context 'with order_by parameter' do
        it 'orders by name ascending' do
          get '/api/v1/contacts', params: { order_by: 'name' }, headers: headers

          names = json_response['data'].map { |c| c['attributes']['name'] }
          expect(names).to eq([ 'Alice Anderson', 'Bob Brown', 'Charlie Cooper' ])
        end

        it 'orders by name descending' do
          get '/api/v1/contacts', params: { order_by: 'name', order_direction: 'desc' }, headers: headers

          names = json_response['data'].map { |c| c['attributes']['name'] }
          expect(names).to eq([ 'Charlie Cooper', 'Bob Brown', 'Alice Anderson' ])
        end

        it 'orders by email ascending' do
          get '/api/v1/contacts', params: { order_by: 'email' }, headers: headers

          emails = json_response['data'].map { |c| c['attributes']['email'] }
          expect(emails).to eq([ 'alice@example.com', 'bob@example.com', 'charlie@example.com' ])
        end

        it 'orders by email descending' do
          get '/api/v1/contacts', params: { order_by: 'email', order_direction: 'desc' }, headers: headers

          emails = json_response['data'].map { |c| c['attributes']['email'] }
          expect(emails).to eq([ 'charlie@example.com', 'bob@example.com', 'alice@example.com' ])
        end

        it 'orders by visit count descending by default' do
          get '/api/v1/contacts', params: { order_by: 'visits' }, headers: headers

          visit_counts = json_response['data'].map { |c| c['attributes']['visits_count'] }
          expect(visit_counts).to eq([ 3, 2, 1 ])
        end

        it 'orders by visit count ascending' do
          get '/api/v1/contacts', params: { order_by: 'visits', order_direction: 'asc' }, headers: headers

          visit_counts = json_response['data'].map { |c| c['attributes']['visits_count'] }
          expect(visit_counts).to eq([ 1, 2, 3 ])
        end
      end

      context 'with combined search and order' do
        let!(:contact4) { create(:contact, organization: organization, name: 'Bob Wilson', email: 'wilson@example.com') }

        it 'searches and orders correctly' do
          get '/api/v1/contacts', params: { search: 'bob', order_by: 'email' }, headers: headers

          results = json_response['data'].map { |c| c['attributes']['name'] }
          expect(results).to eq([ 'Bob Brown', 'Bob Wilson' ])
          expect(results.length).to eq(2)
        end
      end
    end

    context 'with pagination' do
      before do
        # Create more contacts than the default page size
        create_list(:contact, Pagy::DEFAULT[:items] + 5, organization: organization)
      end

      it 'returns paginated results' do
        get api_v1_contacts_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(Pagy::DEFAULT[:items])
        expect(json_response['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 2,
          'total_count' => Pagy::DEFAULT[:items] + 5
        )
      end

      it 'returns the second page' do
        get api_v1_contacts_path, params: { page: 2 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(5) # Remaining items
        expect(json_response['meta']['pagination']['current_page']).to eq(2)
      end

      it 'returns empty array for page beyond range' do
        get api_v1_contacts_path, params: { page: 3 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
        expect(json_response['meta']['pagination']['current_page']).to eq(2) # Last available page
      end
    end

    context 'with error conditions' do
      context 'in index action' do
        it 'handles database errors' do
          allow(Current).to receive(:organization).and_return(organization)
          allow(organization).to receive(:contacts).and_raise(ActiveRecord::StatementInvalid.new("Database connection error"))

          get '/api/v1/contacts', headers: headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'Database connection error' } ],
            'status' => 'error'
          })
        end
      end
    end
  end

  describe 'GET /api/v1/contacts/:id' do
    let(:contact) { create(:contact, organization: organization) }

    context 'with valid id' do
      context 'with visits included' do
        let(:restaurant) { create(:restaurant, organization: organization) }
        let!(:visit) do
          create(:visit,
            organization: organization,
            restaurant: restaurant,
            contacts: [ contact ],
            created_at: 1.day.ago,
            notes: 'Great dinner!'
          )
        end

        before do
          # Attach an image to the visit
          image = visit.images.new
          file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
          image.file.attach(io: File.open(file_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
          image.save!
        end

        it 'returns the contact with visits and their details' do
          get "/api/v1/contacts/#{contact.id}?include=visits", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data']['attributes']['visits']).to be_present
          visit_data = json_response['data']['attributes']['visits'].first

          expect(visit_data).to include(
            'id' => visit.id,
            'date' => visit.date.to_s,
            'title' => visit.title,
            'notes' => 'Great dinner!',
            'rating' => visit.rating
          )

          expect(visit_data['restaurant']).to include(
            'name' => restaurant.name
          )

          # Check images
          expect(visit_data['images'].first).to include(
            'urls' => include(
              'thumbnail',
              'small',
              'medium'
            )
          )
        end

        it 'handles database errors' do
          # Create doubles
          contacts = double('ActiveRecord::Relation')

          # Ensure we're using our mock organization
          allow(Current).to receive(:organization).and_return(organization)
          allow(organization).to receive(:contacts).and_return(contacts)
          expect(contacts).to receive(:find).with(contact.id.to_s).and_raise(ActiveRecord::ConnectionTimeoutError.new("could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)"))

          get "/api/v1/contacts/#{contact.id}?include=visits", headers: headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors']).to eq([ {
            'code' => 'general_error',
            'detail' => 'could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)'
          } ])
          # No meta field in the error response
        end
      end
    end

    context 'with invalid id' do
      it 'returns 404 if contact not found' do
        other_contact = create(:contact)
        get "/api/v1/contacts/#{other_contact.id}", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
      end

      context "when include parameter is specified" do
        it "accepts the include parameter" do
          get api_v1_contact_path(contact), params: { include: "visits" }, headers: headers

          expect(response).to have_http_status(:ok)
          # We're not checking for visits yet, just making sure the parameter doesn't break anything
          expect(json_response["data"]["attributes"]["name"]).to eq(contact.name)
        end
      end
    end

    context 'with error conditions' do
      context 'in show action' do
        context 'with database errors' do
          it 'handles database errors during contact lookup' do
            # Create a double that will raise the error
            contacts = double('ActiveRecord::Relation')
            allow(Current).to receive(:organization).and_return(organization)
            allow(organization).to receive(:contacts).and_return(contacts)
            allow(contacts).to receive(:find).and_raise(
              ActiveRecord::ConnectionTimeoutError.new("Database error")
            )

            get "/api/v1/contacts/1", headers: headers

            expect(response).to have_http_status(:internal_server_error)

            # Match the actual error response format
            expect(json_response['status']).to eq('error')
            expect(json_response['errors']).to include(
              include('code' => 'general_error', 'detail' => 'Database error')
            )
          end

          it 'handles database errors during association loading' do
            contact = create(:contact, organization: organization)
            allow_any_instance_of(ActiveRecord::Relation).to receive(:first)
              .and_raise(ActiveRecord::ConnectionTimeoutError.new("Database error"))

            get "/api/v1/contacts/#{contact.id}?include=visits", headers: headers

            expect(response).to have_http_status(:internal_server_error)

            # Match the actual error response format
            expect(json_response['status']).to eq('error')
            expect(json_response['errors']).to include(
              include('code' => 'general_error', 'detail' => 'Database error')
            )
          end
        end
      end
    end
  end

  describe 'POST /api/v1/contacts' do
    context 'with valid attributes' do
      let(:valid_attributes) do
        {
          contact: {
            name: 'John Doe',
            email: 'john@example.com',
            phone: '+1234567890',
            notes: 'Test notes'
          }
        }
      end

      it 'creates a new contact' do
        expect {
          post '/api/v1/contacts', params: valid_attributes, headers: headers, as: :json
        }.to change(organization.contacts, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']).to include(
          'name' => 'John Doe',
          'email' => 'john@example.com'
        )
      end

      it 'processes avatar successfully' do
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        avatar = fixture_file_upload(file_path, 'image/jpeg')

        post api_v1_contacts_path, params: {
          contact: valid_attributes[:contact].merge(avatar: avatar)
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['avatar_urls']).to include(
          'medium',
          'thumbnail'
        )
      end

      it 'handles invalid file type' do
        file_path = Rails.root.join('spec', 'fixtures', 'test.txt')
        avatar = fixture_file_upload(file_path, 'text/plain')

        post api_v1_contacts_path, params: {
          contact: valid_attributes[:contact].merge(avatar: avatar)
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(
          include('code' => 'validation_error', 'detail' => include('Invalid file type'))
        )
      end
    end
  end

  describe 'PATCH /api/v1/contacts/:id' do
    let(:contact) { create(:contact, organization: organization) }

    it 'updates the contact successfully' do
      patch "/api/v1/contacts/#{contact.id}", params: {
        contact: { name: 'Updated Name' }
      }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['name']).to eq('Updated Name')
    end

    it 'replaces existing avatars' do
      # First, attach an initial avatar
      file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
      initial_avatar = fixture_file_upload(file_path, 'image/jpeg')
      contact.avatar.attach(initial_avatar)

      # Then try to replace it
      new_avatar = fixture_file_upload(file_path, 'image/jpeg')

      patch api_v1_contact_path(contact), params: {
        contact: { avatar: new_avatar }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['avatar_urls']).to include(
        'medium',
        'thumbnail'
      )
    end

    it 'handles invalid file type' do
      file_path = Rails.root.join('spec', 'fixtures', 'test.txt')
      avatar = fixture_file_upload(file_path, 'text/plain')

      patch api_v1_contact_path(contact), params: {
        contact: { avatar: avatar }
      }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include(
        include('code' => 'validation_error', 'detail' => include('Invalid file type'))
      )
    end
  end

  describe 'DELETE /api/v1/contacts/:id' do
    let(:contact) { create(:contact, organization: organization) }

    it 'deletes the contact' do
      delete api_v1_contact_path(contact), headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(Contact.exists?(contact.id)).to be false
    end

    context 'with unauthorized access' do
      let(:other_org) { create(:organization) }
      let(:other_contact) { create(:contact, organization: other_org) }

      it 'returns not found for contact from another organization' do
        delete api_v1_contact_path(other_contact), headers: headers

        expect(response).to have_http_status(:not_found)
        expect(Contact.exists?(other_contact.id)).to be true
      end
    end

    context 'with error conditions' do
      context 'in destroy action' do
        it 'handles destroy errors' do
          allow_any_instance_of(Contact).to receive(:destroy!).and_raise(ActiveRecord::ConnectionTimeoutError.new("could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)"))

          delete "/api/v1/contacts/#{contact.id}", headers: headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)' } ],
            'status' => 'error'
          })
        end
      end
    end
  end

  describe 'GET /api/v1/contacts/search' do
    let!(:contact1) { create(:contact, organization: organization, name: 'John Doe', email: 'john@example.com') }
    let!(:contact2) { create(:contact, organization: organization, name: 'Jane Smith', email: 'jane@example.com') }
    let!(:contact3) { create(:contact, organization: organization, name: 'Bob Wilson', email: 'bob@example.com') }
    let!(:other_org_contact) { create(:contact, name: 'John Smith', email: 'john.smith@example.com') }

    it 'returns contacts matching the query' do
      get search_api_v1_contacts_path, params: { query: 'john' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'][0]['attributes']['name']).to eq('John Doe')
    end

    it 'returns multiple matching contacts' do
      get search_api_v1_contacts_path, params: { query: '@example.com' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(3)
    end

    it 'returns empty array when no matches found' do
      get search_api_v1_contacts_path, params: { query: 'nonexistent' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_empty
    end

    it 'includes pagination metadata' do
      get search_api_v1_contacts_path, params: { query: '@example.com' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['meta']['pagination']).to include(
        'current_page',
        'total_pages',
        'total_count'
      )
    end

    context 'with error conditions' do
      context 'in search action' do
        it 'handles search errors' do
          allow(Contact).to receive(:search).and_raise(ActiveRecord::StatementInvalid.new("Database connection error"))

          get "/api/v1/contacts/search", params: { query: 'test' }, headers: headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'Database connection error' } ],
            'status' => 'error'
          })
        end
      end
    end
  end
end
