require 'rails_helper'

RSpec.describe Restaurants::PriceLevelsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:restaurant) { create(:restaurant, organization: organization, price_level: 2) }
  let(:locale) { 'en' }

  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    sign_in user
    # Set Current.organization for the test
    Current.organization = organization

    puts "\n=== Test Setup ==="
    puts "Organization ID: #{organization.id}"
    puts "User ID: #{user.id}"
    puts "Restaurant ID: #{restaurant.id}"
    puts "User's organizations: #{user.organizations.pluck(:id)}"
    puts "Current.organization: #{Current.organization&.id}"
    puts "Restaurant organization: #{restaurant.organization_id}"
    puts "Restaurant exists?: #{Restaurant.exists?(restaurant.id)}"
    puts "Restaurant in organization?: #{Current.organization.restaurants.exists?(restaurant.id)}"
    puts "==================="
  end

  after do
    # Reset Current.organization after each test
    Current.organization = nil
  end

  # Helper method to debug request
  def debug_request
    puts "\n====== DEBUG ======"
    puts "Request path: #{request.path}"
    puts "Request method: #{request.method}"
    puts "Session: #{session.inspect}"
    puts "Params: #{controller.params.inspect}"
    puts "=================="
  end

  # Helper method to simulate native app
  def set_native_headers
    @request.headers["HTTP_USER_AGENT"] = "Turbo Native iOS"
    puts "\n=== Debug Headers ==="
    puts "User Agent: #{@request.headers['HTTP_USER_AGENT']}"
    puts "Native App?: #{@controller&.send(:hotwire_native_app?)}"
    puts "==================="
  end

  describe 'GET #edit' do
    context 'when authenticated' do
      context 'with native app' do
        before do
          set_native_headers
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
          get :edit, params: { restaurant_id: restaurant.id, locale: locale }
          debug_request
        end

        it 'renders edit template' do
          expect(response).to have_http_status(:success)
          expect(response).to render_template('restaurants/price_levels/edit')
        end
      end

      context 'with web app' do
        before do
          allow(controller).to receive(:hotwire_native_app?).and_return(false)
          get :edit, params: { restaurant_id: restaurant.id, locale: locale }
          debug_request
        end

        it 'returns success status' do
          expect(response).to have_http_status(:success)
        end

        it 'renders edit template' do
          expect(response).to render_template('restaurants/price_levels/edit')
        end
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get :edit, params: { restaurant_id: restaurant.id, locale: locale }
        debug_request
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { restaurant: { price_level: 3 }, locale: locale } }
    let(:invalid_params) { { restaurant: { price_level: 6 }, locale: locale } }

    context 'when authenticated' do
      context 'with native app' do
        before do
          set_native_headers
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
        end

        context 'with valid params' do
          it 'updates the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            debug_request
            expect(restaurant.reload.price_level).to eq(3)
          end

          it 'redirects to restaurant path' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            debug_request
            # Fix: Use a different approach to verify the redirect
            expect(response).to be_redirect
            redirect_url = response.location
            expect(redirect_url).to include(restaurant_path(id: restaurant.id, locale: locale))
            expect(redirect_url).to match(/t=\d+/)
          end
        end

        context 'with invalid params' do
          it 'does not update the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            debug_request
            expect(restaurant.reload.price_level).not_to eq(6)
          end

          it 'renders edit template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            debug_request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template('restaurants/price_levels/edit')
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
            debug_request
            expect(restaurant.reload.price_level).to eq(3)
          end

          it 'renders turbo stream with updated price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(valid_params)
            debug_request
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include(dom_id(restaurant, :price_level))
          end
        end

        context 'with invalid params' do
          it 'does not update the price level' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            debug_request
            expect(restaurant.reload.price_level).not_to eq(6)
          end

          it 'renders edit template with unprocessable entity status' do
            patch :update, params: { restaurant_id: restaurant.id }.merge(invalid_params)
            debug_request
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
        debug_request
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not update the price level' do
        expect(restaurant.reload.price_level).not_to eq(3)
      end
    end

    context 'when accessing restaurant from another organization' do
      let(:other_organization) { create(:organization) }
      let(:other_restaurant) { create(:restaurant, organization: other_organization) }

      it 'returns not found' do
        patch :update, params: { restaurant_id: other_restaurant.id }.merge(valid_params)
        debug_request
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
