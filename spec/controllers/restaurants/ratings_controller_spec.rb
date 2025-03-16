require 'rails_helper'

RSpec.describe Restaurants::RatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }

  before do
    sign_in user
  end

  describe 'GET #edit' do
    context 'when authenticated' do
      context 'with native app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
          get :edit, params: { restaurant_id: restaurant.id }
        end

        it 'renders edit_native template' do
          expect(response).to render_template('restaurants/ratings/edit_native')
        end

        it 'returns success status' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with web app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(false)
          get :edit, params: { restaurant_id: restaurant.id }
        end

        it 'returns success status' do
          expect(response).to have_http_status(:success)
        end

        it 'renders turbo stream with edit template' do
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it 'replaces the rating frame' do
          expect(response.body).to include("turbo-stream action=\"replace\" target=\"rating_restaurant_#{restaurant.id}\"")
        end
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get :edit, params: { restaurant_id: restaurant.id }
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { restaurant: { rating: 4 } } }
    let(:invalid_params) { { restaurant: { rating: 6 } } }

    context 'when authenticated' do
      context 'with native app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
        end

        context 'with valid params' do
          it 'updates the rating' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(restaurant.reload.rating).to eq(4)
          end

          it 'redirects to restaurant path' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: nil))
          end
        end

        context 'with invalid params' do
          it 'does not update the rating' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(restaurant.reload.rating).not_to eq(6)
          end

          it 'renders edit_native template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(response).to render_template('restaurants/ratings/edit_native')
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'with web app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(false)
        end

        context 'with valid params' do
          it 'updates the rating' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(restaurant.reload.rating).to eq(4)
          end

          it 'renders turbo stream with updated rating' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(response.media_type).to eq Mime[:turbo_stream]
          end

          it 'replaces the rating frame with updated content' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(response.body).to include("turbo-stream action=\"replace\" target=\"rating_restaurant_#{restaurant.id}\"")
          end
        end

        context 'with invalid params' do
          it 'does not update the rating' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(restaurant.reload.rating).not_to eq(6)
          end

          it 'renders edit template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(response).to render_template('restaurants/ratings/edit')
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not update the rating' do
        expect(restaurant.reload.rating).not_to eq(4)
      end
    end

    context 'when accessing another user\'s restaurant' do
      let(:other_user) { create(:user) }
      let(:other_restaurant) { create(:restaurant, user: other_user) }

      it 'raises RecordNotFound' do
        expect {
          patch :update, params: { restaurant_id: other_restaurant.id }.merge(valid_params)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
