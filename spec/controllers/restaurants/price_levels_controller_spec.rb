require 'rails_helper'

RSpec.describe Restaurants::PriceLevelsController, type: :controller do
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
          expect(response).to render_template('restaurants/price_levels/edit_native')
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
    let(:valid_params) { { restaurant: { price_level: 3 } } }
    let(:invalid_params) { { restaurant: { price_level: 6 } } }

    context 'when authenticated' do
      context 'with native app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
        end

        context 'with valid params' do
          it 'updates the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(restaurant.reload.price_level).to eq(3)
          end

          it 'redirects to restaurant path' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: nil))
          end
        end

        context 'with invalid params' do
          it 'does not update the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(restaurant.reload.price_level).not_to eq(6)
          end

          it 'renders edit_native template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(response).to render_template('restaurants/price_levels/edit_native')
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'with web app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(false)
        end

        context 'with valid params' do
          it 'updates the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(restaurant.reload.price_level).to eq(3)
          end

          it 'renders turbo stream with updated price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            expect(response.media_type).to eq Mime[:turbo_stream]
          end
        end

        context 'with invalid params' do
          it 'does not update the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(restaurant.reload.price_level).not_to eq(6)
          end

          it 'renders edit template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            expect(response).to render_template('restaurants/price_levels/edit')
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

      it 'does not update the price level' do
        expect(restaurant.reload.price_level).not_to eq(3)
      end
    end
  end
end
