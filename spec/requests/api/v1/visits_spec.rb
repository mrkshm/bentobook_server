require 'rails_helper'

RSpec.describe 'Api::V1::Visits', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] = 10
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

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
    Rails.application.routes.default_url_options[:host] = 'example.com'
  end

  def json_response
    @json_response ||= JSON.parse(response.body, symbolize_names: true)
  end

  describe 'GET /api/v1/visits' do
    context 'with no visits' do
      it 'returns an empty list' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:status]).to eq('success')
        expect(json_response[:data]).to eq([])
        expect(json_response[:meta][:pagination]).to include(
          current_page: 1,
          total_pages: 0,
          total_count: 0
        )
      end
    end

    context 'with a visit' do
      let!(:visit) { create(:visit, user: user, restaurant: restaurant) }

      it 'returns the visit' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:status]).to eq('success')
        expect(json_response[:data]).to be_an(Array)
        visit_data = json_response[:data].first
        expect(visit_data[:attributes]).to include(
          date: visit.date.as_json,
          title: visit.title,
          notes: visit.notes,
          rating: visit.rating
        )
      end
    end

    context 'with a visit that has an image' do
      let!(:visit) { create(:visit, user: user, restaurant: restaurant) }
      let(:image_file) { fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg') }

      before do
        visit.images.create!(file: image_file)
      end

      it 'returns the visit with image urls' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        visit_data = json_response[:data].first
        expect(visit_data[:attributes][:images]).to be_an(Array)
        expect(visit_data[:attributes][:images].first[:urls]).to include(
          thumbnail: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          small: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          medium: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          large: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          original: a_string_matching(%r{^http://example\.com/rails/active_storage/blobs/redirect/.+/\d{14}_test_image\.jpg$})
        )
      end
    end

    context 'with a visit that has multiple images' do
      let!(:visit) { create(:visit, user: user, restaurant: restaurant) }
      let(:image_file1) { fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg') }
      let(:image_file2) { fixture_file_upload('spec/fixtures/files/test_image2.jpg', 'image/jpeg') }

      before do
        visit.images.create!(file: image_file1)
        visit.images.create!(file: image_file2)
      end

      it 'returns the visit with all image urls' do
        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:ok)
        visit_data = json_response[:data].first
        expect(visit_data[:attributes][:images]).to be_an(Array)
        expect(visit_data[:attributes][:images].length).to eq(2)

        # Check first image
        image1_data = visit_data[:attributes][:images][0]
        expect(image1_data[:urls]).to include(
          thumbnail: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          small: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          medium: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          large: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image\.jpg$}),
          original: a_string_matching(%r{^http://example\.com/rails/active_storage/blobs/redirect/.+/\d{14}_test_image\.jpg$})
        )

        # Check second image
        image2_data = visit_data[:attributes][:images][1]
        expect(image2_data[:urls]).to include(
          thumbnail: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image2\.jpg$}),
          small: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image2\.jpg$}),
          medium: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image2\.jpg$}),
          large: a_string_matching(%r{^http://example\.com/rails/active_storage/representations/redirect/.+/\d{14}_test_image2\.jpg$}),
          original: a_string_matching(%r{^http://example\.com/rails/active_storage/blobs/redirect/.+/\d{14}_test_image2\.jpg$})
        )
      end
    end

    context 'with pagination and images' do
      let(:image_file) { fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg') }

      before do
        # Disable the set_filename callback for this test
        Image.skip_callback(:create, :after, :set_filename)

        15.times do |i|
          visit = create(:visit, user: user)
          image = visit.images.new
          image.file.attach(
            io: image_file.open,
            filename: "test_image_#{i}.jpg",
            content_type: 'image/jpeg'
          )
          image.save!
        end

        # Re-enable the callback after creating images
        Image.set_callback(:create, :after, :set_filename)
      end

      it 'returns paginated visits with images' do
        get '/api/v1/visits?page=2&per_page=5', headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:data].length).to eq(5)
        expect(json_response[:meta][:pagination]).to include(
          current_page: 2,
          per_page: "5",
          total_pages: 3,
          total_count: 15
        )

        visit_data = json_response[:data].first
        expect(visit_data[:attributes][:images]).to be_present
        expect(visit_data[:attributes][:images].first[:urls]).to include(
          :thumbnail,
          :small,
          :medium,
          :large,
          :original
        )
      end
    end

    context 'GET /api/v1/visits with error' do
      it 'logs the error and returns an internal server error' do
        allow_any_instance_of(Api::V1::VisitsController).to receive(:current_user).and_return(user)
        allow(user.visits).to receive(:includes).with(:restaurant, :contacts, :images).and_raise(StandardError.new("Test error"))

        get '/api/v1/visits', headers: @headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:errors][0][:code]).to eq("unprocessable_entity")
        expect(json_response[:errors][0][:detail]).to eq('Failed to fetch visits')
      end
    end

    context 'when the visit exists' do
      let(:visit) { create(:visit, user: user) }

      it 'returns the visit' do
        get "/api/v1/visits/#{visit.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        visit_data = json_response[:data]
        expect(visit_data[:attributes].keys.map(&:to_s)).to include(
          'date',
          'title',
          'notes',
          'rating',
          'contacts',
          'price_paid'
        )
      end
    end

    context 'when the visit does not exist' do
      it 'returns a not found error' do
        get '/api/v1/visits/0', headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(json_response[:status]).to eq('error')
        expect(json_response[:errors].first[:detail]).to eq('Visit not found')
      end
    end

    context 'when an unexpected error occurs' do
      let(:visit) { create(:visit, user: user) }

      it 'logs the error and returns an internal server error' do
        allow_any_instance_of(Visit).to receive(:contacts).and_raise(StandardError.new("Test error"))

        get "/api/v1/visits/#{visit.id}", headers: @headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response[:status]).to eq('error')
        expect(json_response[:errors].first[:detail]).to eq('Failed to retrieve visit')
      end
    end
  end

  describe 'DELETE /api/v1/visits/:id' do
    context 'when the visit exists' do
      let!(:visit) { create(:visit, user: user) }

      it 'deletes the visit' do
        expect {
          delete "/api/v1/visits/#{visit.id}", headers: @headers
        }.to change(Visit, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when the visit does not exist' do
      it 'returns a not found error' do
        delete "/api/v1/visits/0", headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:errors][0][:code]).to eq("unprocessable_entity")
        expect(json_response[:errors][0][:detail]).to eq("Visit not found")
      end
    end

    context 'when there is an error deleting the visit' do
      let!(:visit) { create(:visit, user: user) }

      it 'returns an internal server error' do
        allow_any_instance_of(Visit).to receive(:destroy).and_raise(StandardError.new("Test error"))

        delete "/api/v1/visits/#{visit.id}", headers: @headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:errors][0][:code]).to eq("unprocessable_entity")
        expect(json_response[:errors][0][:detail]).to eq("Failed to delete visit")
      end
    end
  end

  describe 'GET /api/v1/visits/:id' do
    context 'when the visit exists' do
      let(:visit) { create(:visit, user: user) }

      it 'returns the visit' do
        get "/api/v1/visits/#{visit.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        visit_data = json_response[:data]
        expect(visit_data[:attributes].keys.map(&:to_s)).to include(
          'date',
          'title',
          'notes',
          'rating',
          'contacts',
          'price_paid'
        )
      end
    end

    context 'when the visit does not exist' do
      it 'returns a not found error' do
        get "/api/v1/visits/0", headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:errors][0][:code]).to eq("unprocessable_entity")
        expect(json_response[:errors][0][:detail]).to eq("Visit not found")
      end
    end

    context 'when there is an error retrieving the visit' do
      let(:visit) { create(:visit, user: user) }

      it 'returns an internal server error' do
        allow_any_instance_of(Visit).to receive(:contacts).and_raise(StandardError.new("Test error"))

        get "/api/v1/visits/#{visit.id}", headers: @headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response[:status]).to eq("error")
        expect(json_response[:errors][0][:code]).to eq("unprocessable_entity")
        expect(json_response[:errors][0][:detail]).to eq("Failed to retrieve visit")
      end
    end
  end
end
