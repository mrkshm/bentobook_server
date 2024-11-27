require 'rails_helper'

RSpec.describe 'Api::V1::Contacts', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] ||= 10 # Set default items per page if not already set
  end

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
      before do
        create_list(:contact, 3, user: user)
      end

      it 'returns paginated contacts' do
        get '/api/v1/contacts', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data'].length).to eq(3)
        expect(json_response['data'].first).to include(
          'id',
          'type' => 'contact',
          'attributes' => hash_including(
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
        )
      end

      it 'orders contacts by created_at desc' do
        get '/api/v1/contacts', headers: @headers

        created_ats = json_response['data'].map { |c| Time.parse(c['attributes']['created_at']) }
        expect(created_ats).to eq(created_ats.sort.reverse)
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
  end

  describe 'GET /api/v1/contacts/:id' do
    let(:contact) { create(:contact, user: user) }

    it 'returns the contact' do
      get api_v1_contact_path(contact), headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["attributes"]["name"]).to eq(contact.name)
      expect(json_response["data"]["attributes"]["email"]).to eq(contact.email)
    end

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
        post '/api/v1/contacts',
             params: {
               contact: contact_attributes.merge(
                 avatar: fixture_file_upload('invalid.txt', 'text/plain')
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
  end

  describe 'PATCH /api/v1/contacts/:id' do
    let(:contact) { create(:contact, user: user) }

    context 'with valid parameters' do
      it 'updates the contact' do
        patch api_v1_contact_path(contact),
              params: {
                contact: {
                  name: "Updated Name",
                  email: "updated@example.com",
                  phone: "+1-555-0123"
                }
              },
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['name']).to eq("Updated Name")
        expect(json_response['data']['attributes']['email']).to eq("updated@example.com")
        expect(json_response['data']['attributes']['phone']).to eq("+1-555-0123")
      end

      it 'updates the contact with a new avatar' do
        patch api_v1_contact_path(contact),
              params: {
                contact: {
                  name: "Updated Name",
                  avatar: fixture_file_upload("spec/fixtures/files/avatar.jpg", "image/jpeg")
                }
              },
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['name']).to eq("Updated Name")
        expect(json_response['data']['attributes']['avatar_urls']).to be_present
        expect(json_response['data']['attributes']['avatar_urls']['original']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for missing required fields' do
        patch api_v1_contact_path(contact),
              params: {
                contact: {
                  name: "",
                  email: "invalid-email"
                }
              },
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors']).to include(
          hash_including(
            'code' => 'validation_error',
            'source' => { 'pointer' => '/data/attributes/name' }
          )
        )
      end

      it 'returns error for invalid avatar file' do
        patch api_v1_contact_path(contact),
              params: {
                contact: {
                  avatar: fixture_file_upload("spec/fixtures/files/invalid.txt", "text/plain")
                }
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

    context 'with unauthorized access' do
      let(:other_contact) { create(:contact) }

      it 'returns not found for other user\'s contact' do
        patch api_v1_contact_path(other_contact),
              params: { contact: { name: "Updated Name" } },
              headers: @headers

        expect(response).to have_http_status(:not_found)
      end
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
  end
end
