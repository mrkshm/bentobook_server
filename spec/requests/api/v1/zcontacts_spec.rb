require 'rails_helper'

RSpec.describe 'Api::V1::Contacts', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] ||= 10 # Set default items per page if not already set
  end

  # Custom error class that won't be caught by the general handler
  class TestError < Exception; end

  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
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

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
  end

  describe 'GET /api/v1/contacts' do
    context 'with no contacts' do
      it 'returns an empty list' do
        get '/api/v1/contacts', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_empty
        expect(json_response['meta']).to include('timestamp')
        expect(json_response['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 0,
          'per_page' => 10  # matches Pagy::DEFAULT[:limit]
        )
      end
    end

    context 'with multiple contacts' do
      let!(:contact1) { create(:contact, user: user, name: 'Alice Anderson', email: 'alice@example.com', created_at: 2.days.ago) }
      let!(:contact2) { create(:contact, user: user, name: 'Bob Brown', email: 'bob@example.com', created_at: 1.day.ago) }
      let!(:contact3) { create(:contact, user: user, name: 'Charlie Cooper', email: 'charlie@example.com', created_at: Time.current) }

      before do
        # Create some visits
        create(:visit, user: user, contacts: [ contact1 ])
        create_list(:visit, 2, user: user, contacts: [ contact2 ])
        create_list(:visit, 3, user: user, contacts: [ contact3 ])
      end

      it 'returns contacts ordered by created_at desc by default' do
        get '/api/v1/contacts', headers: @headers

        contact_ids = json_response['data'].map { |c| c['id'].to_i }
        expect(contact_ids).to eq([ contact3.id, contact2.id, contact1.id ])
      end

      context 'with search parameter' do
        it 'returns matching contacts' do
          get '/api/v1/contacts', params: { search: 'bob' }, headers: @headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Bob Brown')
        end

        it 'returns empty array for no matches' do
          get '/api/v1/contacts', params: { search: 'xyz' }, headers: @headers

          expect(json_response['data']).to be_empty
        end
      end

      context 'with order_by parameter' do
        it 'orders by name ascending' do
          get '/api/v1/contacts', params: { order_by: 'name' }, headers: @headers

          names = json_response['data'].map { |c| c['attributes']['name'] }
          expect(names).to eq([ 'Alice Anderson', 'Bob Brown', 'Charlie Cooper' ])
        end

        it 'orders by name descending' do
          get '/api/v1/contacts', params: { order_by: 'name', order_direction: 'desc' }, headers: @headers

          names = json_response['data'].map { |c| c['attributes']['name'] }
          expect(names).to eq([ 'Charlie Cooper', 'Bob Brown', 'Alice Anderson' ])
        end

        it 'orders by email ascending' do
          get '/api/v1/contacts', params: { order_by: 'email' }, headers: @headers

          emails = json_response['data'].map { |c| c['attributes']['email'] }
          expect(emails).to eq([ 'alice@example.com', 'bob@example.com', 'charlie@example.com' ])
        end

        it 'orders by email descending' do
          get '/api/v1/contacts', params: { order_by: 'email', order_direction: 'desc' }, headers: @headers

          emails = json_response['data'].map { |c| c['attributes']['email'] }
          expect(emails).to eq([ 'charlie@example.com', 'bob@example.com', 'alice@example.com' ])
        end

        it 'orders by visit count descending by default' do
          get '/api/v1/contacts', params: { order_by: 'visits' }, headers: @headers

          visit_counts = json_response['data'].map { |c| c['attributes']['visits_count'] }
          expect(visit_counts).to eq([ 3, 2, 1 ])
        end

        it 'orders by visit count ascending' do
          get '/api/v1/contacts', params: { order_by: 'visits', order_direction: 'asc' }, headers: @headers

          visit_counts = json_response['data'].map { |c| c['attributes']['visits_count'] }
          expect(visit_counts).to eq([ 1, 2, 3 ])
        end
      end

      context 'with combined search and order' do
        let!(:contact4) { create(:contact, user: user, name: 'Bob Wilson', email: 'wilson@example.com') }

        it 'searches and orders correctly' do
          get '/api/v1/contacts', params: { search: 'bob', order_by: 'email' }, headers: @headers

          results = json_response['data'].map { |c| c['attributes']['name'] }
          expect(results).to eq([ 'Bob Brown', 'Bob Wilson' ])
          expect(results.length).to eq(2)
        end
      end
    end

    context 'with pagination' do
      before do
        # Create more contacts than the default page size
        create_list(:contact, Pagy::DEFAULT[:items] + 5, user: user)
      end

      it 'returns paginated results' do
        get api_v1_contacts_path, headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(Pagy::DEFAULT[:items])
        expect(json_response['meta']['pagination']['total_pages']).to eq(2)
      end

      it 'returns the second page' do
        get api_v1_contacts_path, params: { page: 2 }, headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(5) # Remaining items
        expect(json_response['meta']['pagination']['current_page']).to eq(2)
      end

      it 'returns empty array for page beyond range' do
        get api_v1_contacts_path, params: { page: 3 }, headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
        expect(json_response['meta']['pagination']['current_page']).to eq(2) # Last available page
      end
    end

    context 'with error conditions' do
      context 'in index action' do
        before do
          allow(Contact).to receive(:search).and_raise(ActiveRecord::StatementInvalid.new("Database connection error"))
        end

        it 'handles database errors gracefully' do
          contacts = instance_double(ActiveRecord::Relation)
          paginated = instance_double(ActiveRecord::Relation)
          allow(user).to receive(:contacts).and_return(contacts)
          allow(contacts).to receive(:where).and_raise(ActiveRecord::StatementInvalid.new("Database connection error"))

          get '/api/v1/contacts', params: { search: 'test' }, headers: @headers

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
    let(:contact) { create(:contact, user: user) }

    context 'with valid id' do
      it 'returns the contact' do
        get "/api/v1/contacts/#{contact.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']).to include(
          'name' => contact.name,
          'email' => contact.email
        )
      end

      context 'with visits included' do
        let(:restaurant) { create(:restaurant, user: user) }
        let!(:visit) do
          create(:visit,
            user: user,
            restaurant: restaurant,
            contacts: [ contact ],
            date: Date.current,
            title: 'Birthday dinner',
            notes: 'Great time',
            rating: 4
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
          get "/api/v1/contacts/#{contact.id}?include=visits", headers: @headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data']['attributes']['visits']).to be_present

          visit_data = json_response['data']['attributes']['visits'].first
          expect(visit_data).to include(
            'id' => visit.id,
            'date' => visit.date.as_json,
            'title' => 'Birthday dinner',
            'notes' => 'Great time',
            'rating' => 4
          )

          # Check restaurant data
          expect(visit_data['restaurant']).to include(
            'id' => restaurant.id,
            'name' => restaurant.combined_name,
            'cuisine_type' => restaurant.cuisine_type&.name
          )
          expect(visit_data['restaurant']['location']).to include(
            'address' => restaurant.combined_address,
            'latitude' => restaurant.combined_latitude&.to_f,
            'longitude' => restaurant.combined_longitude&.to_f
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

          # Ensure we're using our mock user
          allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(
            double('User', contacts: contacts)
          )
          expect(contacts).to receive(:find).with(contact.id.to_s).and_raise(ActiveRecord::ConnectionTimeoutError.new("Database error"))

          get "/api/v1/contacts/#{contact.id}?include=visits", headers: @headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors']).to eq([ {
            'code' => 'general_error',
            'detail' => 'Database error'
          } ])
          expect(json_response['meta']).to have_key('timestamp')
        end
      end
    end

    context 'with invalid id' do
      it 'returns 404 if contact not found' do
        other_contact = create(:contact)
        get "/api/v1/contacts/#{other_contact.id}", headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
      end

      context "when include parameter is specified" do
        it "accepts the include parameter" do
          get api_v1_contact_path(contact), params: { include: "visits" }, headers: @headers

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
            allow(contacts).to receive(:find).and_raise(
              ActiveRecord::ConnectionTimeoutError.new("Database connection timeout")
            )

            # Allow the controller to access current_user.contacts
            allow_any_instance_of(Api::V1::ContactsController).to receive(:current_user).and_return(user)
            allow(user).to receive(:contacts).and_return(contacts)

            get "/api/v1/contacts/1", headers: @headers

            expect(response).to have_http_status(:internal_server_error)

            # Use match instead of eq for more flexible matching
            expect(json_response).to match({
              'status' => 'error',
              'errors' => [ {
                'code' => 'general_error',
                'detail' => 'Database error'
              } ],
              'meta' => {
                'timestamp' => match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
              }
            })
          end

          it 'handles database errors during association loading' do
            contact = create(:contact, user: user)
            allow_any_instance_of(ActiveRecord::Relation).to receive(:first)
              .and_raise(ActiveRecord::ConnectionTimeoutError.new("Database connection timeout"))

            get "/api/v1/contacts/#{contact.id}?include=visits", headers: @headers

            expect(response).to have_http_status(:internal_server_error)

            # Use match instead of eq for more flexible matching
            expect(json_response).to match({
              'status' => 'error',
              'errors' => [ {
                'code' => 'general_error',
                'detail' => 'Database error'
              } ],
              'meta' => {
                'timestamp' => match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
              }
            })
          end
        end
      end
    end
  end

  describe 'POST /api/v1/contacts' do
    context 'with valid parameters' do
      it 'creates a new contact' do
        expect {
          post '/api/v1/contacts',
               params: { contact: contact_attributes },
               headers: @headers

          expect(response).to have_http_status(:created)
          expect(json_response['status']).to eq('success')
          expect(json_response['data']['type']).to eq('contact')
          expect(json_response['data']['attributes']).to include(
            'name' => contact_attributes[:name],
            'email' => contact_attributes[:email],
            'city' => contact_attributes[:city],
            'country' => contact_attributes[:country],
            'phone' => contact_attributes[:phone],
            'notes' => contact_attributes[:notes]
          )
        }.to change(Contact, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for missing required fields' do
        post '/api/v1/contacts',
             params: { contact: { email: 'invalid' } },
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors']).to include(
          hash_including('code' => 'validation_error')
        )
      end
    end

    context 'with avatar' do
      let(:avatar) { fixture_file_upload('test_image.jpg', 'image/jpeg') }

      it 'creates a contact with an avatar' do
        post '/api/v1/contacts',
             params: {
               contact: contact_attributes.merge(
                 avatar: avatar
               )
             },
             headers: @headers

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['avatar_urls']).to include('original')
        expect(Contact.last.avatar).to be_attached
      end

      it 'handles invalid image files' do
        FileUtils.mkdir_p('spec/fixtures/files')
        File.write('spec/fixtures/files/invalid_image.txt', 'Not an image')
        file = fixture_file_upload('invalid_image.txt', 'image/jpeg')

        post '/api/v1/contacts',
             params: {
               contact: contact_attributes.merge(
                 avatar: file
               )
             },
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors']).to include(
          hash_including(
            'code' => 'validation_error',
            'detail' => 'must be a valid image file',
            'source' => { 'pointer' => '/data/attributes/avatar' }
          )
        )
      end
    end

    context 'with error conditions' do
      context 'in create action' do
        let(:new_contact) { build(:contact, user: user) }

        it 'handles validation errors during transaction' do
          contacts = instance_double(ActiveRecord::Relation)
          allow(user).to receive(:contacts).and_return(contacts)
          allow(contacts).to receive(:build).and_return(new_contact)

          # Ensure new_contact has validation errors
          new_contact.errors.add(:name, "can't be blank")
          allow(new_contact).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(new_contact))

          # Use invalid contact attributes
          invalid_contact_attributes = contact_attributes.merge(name: nil)

          post "/api/v1/contacts", params: {
            contact: invalid_contact_attributes
          }, headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to match({
            'status' => 'error',
            'errors' => [
              {
                'code' => 'validation_error',
                'detail' => "can't be blank",
                'source' => { 'pointer' => '/data/attributes/name' }
              }
            ]
          })
        end

        it 'handles database errors during transaction' do
          allow_any_instance_of(Contact).to receive(:save!).and_raise(ActiveRecord::ConnectionTimeoutError.new("Transaction failed"))

          post '/api/v1/contacts', params: {
            contact: contact_attributes
          }, headers: @headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'Transaction failed' } ],
            'status' => 'error'
          })
        end
      end
    end
  end

  describe 'PATCH /api/v1/contacts/:id' do
    let(:contact) { create(:contact, user: user) }
    let(:contact_attributes) { { name: 'Updated Name' } }

    it 'handles database errors during transaction' do
      contacts = instance_double(ActiveRecord::Relation)
      allow_any_instance_of(Api::V1::ContactsController).to receive(:current_user).and_return(user)
      allow(user).to receive(:contacts).and_return(contacts)

      allow(contacts).to receive(:find)
        .with(contact.id.to_s)
        .and_raise(ActiveRecord::ConnectionTimeoutError.new("Database connection timeout"))

      patch "/api/v1/contacts/#{contact.id}", params: {
        contact: contact_attributes
      }, headers: @headers

      expect(response).to have_http_status(:internal_server_error)
      expect(json_response).to eq({
        'status' => 'error',
        'errors' => [ {
          'code' => 'general_error',
          'detail' => 'Database error'
        } ]
      })
    end
  end

  describe 'DELETE /api/v1/contacts/:id' do
    let(:contact) { create(:contact, user: user) }

    it 'deletes the contact' do
      delete api_v1_contact_path(contact), headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(Contact.exists?(contact.id)).to be false
    end

    context 'with unauthorized access' do
      let(:other_contact) { create(:contact) }

      it 'returns not found for other user\'s contact' do
        delete api_v1_contact_path(other_contact), headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(Contact.exists?(other_contact.id)).to be true
      end
    end

    context 'with error conditions' do
      context 'in destroy action' do
        let(:contact) { create(:contact, user: user) }

        it 'handles destroy errors' do
          allow_any_instance_of(Contact).to receive(:destroy!).and_raise(ActiveRecord::ConnectionTimeoutError.new("Delete failed"))

          delete "/api/v1/contacts/#{contact.id}", headers: @headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'Delete failed' } ],
            'status' => 'error'
          })
        end
      end
    end
  end

  describe 'GET /api/v1/contacts/search' do
    let!(:contact1) { create(:contact, user: user, name: 'John Doe', email: 'john@example.com') }
    let!(:contact2) { create(:contact, user: user, name: 'Jane Smith', email: 'jane@example.com') }
    let!(:contact3) { create(:contact, user: user, name: 'Bob Wilson', email: 'bob@example.com') }

    it 'returns contacts matching the query' do
      get search_api_v1_contacts_path, params: { query: 'john' }, headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'][0]['attributes']['name']).to eq('John Doe')
    end

    it 'returns multiple matching contacts' do
      get search_api_v1_contacts_path, params: { query: '@example.com' }, headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(3)
    end

    it 'returns empty array when no matches found' do
      get search_api_v1_contacts_path, params: { query: 'nonexistent' }, headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_empty
    end

    it 'includes pagination metadata' do
      get search_api_v1_contacts_path, params: { query: '@example.com' }, headers: @headers

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
          allow(Contact).to receive(:search).and_raise(ActiveRecord::StatementInvalid.new("Search failed"))

          get "/api/v1/contacts/search", params: { query: 'test' }, headers: @headers

          expect(response).to have_http_status(:internal_server_error)
          expect(json_response).to eq({
            'errors' => [ { 'code' => 'general_error', 'detail' => 'Search failed' } ],
            'status' => 'error'
          })
        end
      end
    end
  end
end
