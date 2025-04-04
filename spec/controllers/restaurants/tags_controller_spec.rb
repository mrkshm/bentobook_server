require 'rails_helper'

RSpec.describe Restaurants::TagsController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }

  before { sign_in user }

  describe "GET #edit" do
    it "assigns the requested restaurant" do
      get :edit, params: { restaurant_id: restaurant.id }
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns available tags" do
      get :edit, params: { restaurant_id: restaurant.id }
      expect(assigns(:available_tags)).to eq(user.restaurants.tag_counts_on(:tags).map(&:name))
    end

    context "when in web app" do
      before do
        allow(controller).to receive(:hotwire_native_app?).and_return(false)
      end

      it "renders the web edit template" do
        get :edit, params: { restaurant_id: restaurant.id }
        expect(response).to render_template(:edit)
      end
    end

    context "when in native app" do
      before do
        allow(controller).to receive(:hotwire_native_app?).and_return(true)
      end

      it "renders the native edit template" do
        get :edit, params: { restaurant_id: restaurant.id }
        expect(response).to render_template(:edit_native)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_tags) { [ 'italian', 'pizza' ].to_json }

      it "updates the restaurant's tags" do
        patch :update, params: { restaurant_id: restaurant.id, restaurant: { tags: new_tags } }
        restaurant.reload
        expect(restaurant.tag_list).to match_array([ 'italian', 'pizza' ])
      end

      it "returns success response for turbo stream request" do
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: new_tags } },
              format: :turbo_stream
        expect(response).to be_successful
      end
    end

    context "with invalid params" do
      it "returns unprocessable entity status" do
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' } },
              format: :turbo_stream,
              xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets error message" do
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' } },
              format: :turbo_stream,
              xhr: true
        expect(response.parsed_body['error']).to be_present
      end

      context "when JSON parsing fails" do
        let(:invalid_json) { '{not valid json' }

        it "handles JSON parse error" do
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: invalid_json } },
                format: :turbo_stream,
                xhr: true

          puts "Response body: #{response.parsed_body.inspect}"
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["error"]).to eq("Invalid tag format")
        end
      end

      context "when rendering HTML format" do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(false)
        end

        it "sets flash alert and renders edit template" do
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' } },
                format: :html

          expect(flash.now[:alert]).to be_present
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when rendering HTML format in native app" do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
        end

        it "sets flash alert and renders edit_native template" do
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' } },
                format: :html

          expect(flash.now[:alert]).to be_present
          expect(response).to render_template(:edit_native)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  context "when restaurant is not found" do
    it "returns not found status" do
      patch :update,
            params: { restaurant_id: 0, restaurant: { tags: '[]' } },
            format: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Restaurant not found")
    end

    it "returns not found status for edit action" do
      get :edit, params: { restaurant_id: 0 }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Restaurant not found")
    end
  end
end
