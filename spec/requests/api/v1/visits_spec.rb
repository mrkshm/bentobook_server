require 'rails_helper'

RSpec.describe 'Api::V1::Visits', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] ||= 10
  end

  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end

  let(:visit_attributes) do
    {
      restaurant_id: restaurant.id,
      date: Date.today,
      title: "Great dinner",
      notes: "Really enjoyed the food",
      rating: 5,
      price_paid_cents: 5000,
      price_paid_currency: "USD"
    }
  end

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
  end

  describe 'GET /api/v1/visits' do
    context 'with no visits' do
      it 'returns an empty list' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_empty
      end
    end

    context 'with multiple visits' do
      let!(:visits) { create_list(:visit, 3, user: user, restaurant: restaurant) }

      it 'returns paginated visits' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data'].length).to eq(3)
        expect(json_response['meta']).to include('pagination')
      end

      it 'orders visits by date desc' do
        old_visit = create(:visit, user: user, restaurant: restaurant, date: 1.week.ago)
        recent_visit = create(:visit, user: user, restaurant: restaurant, date: 1.day.ago)

        get '/api/v1/visits', headers: @headers

        dates = json_response['data'].map { |v| Date.parse(v['attributes']['date']) }
        expect(dates).to eq(dates.sort.reverse)
      end
    end

    context 'with pagination' do
      before { create_list(:visit, 15, user: user, restaurant: restaurant) }

      it 'returns paginated results' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(10)
        expect(json_response['meta']['pagination']['current_page']).to eq(1)
        expect(json_response['meta']['pagination']['total_pages']).to eq(2)
      end

      it 'returns the second page' do
        get '/api/v1/visits', params: { page: 2 }, headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(5)
        expect(json_response['meta']['pagination']['current_page']).to eq(2)
      end

      it 'returns empty array for page beyond range' do
        get '/api/v1/visits', params: { page: 3 }, headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
      end
    end
  end

  describe 'GET /api/v1/visits/:id' do
    let(:visit) { create(:visit, user: user, restaurant: restaurant) }

    it 'returns the visit' do
      get api_v1_visit_path(visit), headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['id']).to eq(visit.id.to_s)
      expect(json_response['data']['type']).to eq('visit')
      expect(json_response['data']['attributes']).to include(
        'date' => visit.date.as_json,
        'title' => visit.title,
        'notes' => visit.notes,
        'rating' => visit.rating
      )
    end

    it 'returns not found for visit belonging to another user' do
      other_visit = create(:visit)
      get "/api/v1/visits/#{other_visit.id}", headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(json_response['status']).to eq('error')
    end
  end

  describe 'POST /api/v1/visits' do
    context 'with valid parameters' do
      it 'creates a new visit' do
        expect {
          post '/api/v1/visits',
               params: { visit: visit_attributes },
               headers: @headers
        }.to change(Visit, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['title']).to eq(visit_attributes[:title])
      end

      it 'creates a visit with an image' do
        image = fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg')

        post '/api/v1/visits',
             params: {
               visit: visit_attributes,
               images: [ image ]
             },
             headers: @headers

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']).to have_key('images')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post '/api/v1/visits',
             params: { visit: visit_attributes.merge(date: nil) },
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
      end
    end
  end

  describe 'PATCH /api/v1/visits/:id' do
    let(:visit) { create(:visit, user: user, restaurant: restaurant) }

    context 'with valid parameters' do
      it 'updates the visit' do
        patch api_v1_visit_path(visit),
              params: { visit: { notes: 'Updated notes' } },
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['notes']).to eq('Updated notes')
      end

      it 'updates the visit with a new image' do
        image = fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg')

        patch api_v1_visit_path(visit),
              params: {
                visit: { notes: 'Updated notes' },
                images: [ image ]
              },
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']).to have_key('images')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        patch api_v1_visit_path(visit),
              params: { visit: { date: nil } },
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
      end
    end
  end

  describe 'DELETE /api/v1/visits/:id' do
    let!(:visit) { create(:visit, user: user, restaurant: restaurant) }

    it 'deletes the visit' do
      expect {
        delete api_v1_visit_path(visit), headers: @headers
      }.to change(Visit, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
    end

    it 'returns not found for non-existent visit' do
      delete '/api/v1/visits/0', headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(json_response['status']).to eq('error')
    end
  end
end
