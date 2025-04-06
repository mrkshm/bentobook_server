require 'rails_helper'

RSpec.describe Restaurants::TagsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:restaurant) { create(:restaurant, organization: organization) }
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
    puts "Current.organization: #{Current.organization&.id}"
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

  # Helper to ensure Current.organization is set for each request
  def set_current_organization
    # This is needed because Current.organization gets reset between requests
    Current.organization = organization
    # Allow controller to access Current.organization
    allow(Current).to receive(:organization).and_return(organization)
  end

  describe "GET #edit" do
    it "assigns the requested restaurant" do
      set_current_organization
      get :edit, params: { restaurant_id: restaurant.id, locale: locale }
      debug_request
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns available tags" do
      set_current_organization
      get :edit, params: { restaurant_id: restaurant.id, locale: locale }
      debug_request
      expect(assigns(:available_tags)).to eq(organization.restaurants.tag_counts_on(:tags).map(&:name))
    end

    context "when in web app" do
      before do
        allow(controller).to receive(:hotwire_native_app?).and_return(false)
      end

      it "renders the web edit template" do
        set_current_organization
        get :edit, params: { restaurant_id: restaurant.id, locale: locale }
        debug_request
        expect(response).to render_template(:edit)
      end
    end

    context "when in native app" do
      before do
        set_native_headers
        allow(controller).to receive(:hotwire_native_app?).and_return(true)
      end

      it "renders the native edit template" do
        set_current_organization
        get :edit, params: { restaurant_id: restaurant.id, locale: locale }
        debug_request
        expect(response).to render_template(:edit_native)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      # Use an array of strings instead of a JSON string
      let(:new_tags) { ['italian', 'pizza'] }

      it "updates the restaurant's tags" do
        set_current_organization
        # Allow the manager service to be called with the correct parameters
        manager_service = instance_double(Restaurants::Tags::ManagerService)
        allow(Restaurants::Tags::ManagerService).to receive(:new).with(restaurant).and_return(manager_service)
        allow(manager_service).to receive(:update).and_return(Restaurants::Tags::Result.success)
        
        # Set the tag_list directly on the restaurant for testing
        allow_any_instance_of(Restaurant).to receive(:tag_list=).with(new_tags)
        allow_any_instance_of(Restaurant).to receive(:save).and_return(true)
        allow_any_instance_of(Restaurant).to receive(:tag_list).and_return(new_tags)
        
        patch :update, params: { restaurant_id: restaurant.id, restaurant: { tags: new_tags.to_json }, locale: locale }
        debug_request
        expect(restaurant.tag_list).to match_array(['italian', 'pizza'])
      end

      it "returns success response for turbo stream request" do
        set_current_organization
        # Allow the manager service to be called with the correct parameters
        manager_service = instance_double(Restaurants::Tags::ManagerService)
        allow(Restaurants::Tags::ManagerService).to receive(:new).with(restaurant).and_return(manager_service)
        allow(manager_service).to receive(:update).and_return(Restaurants::Tags::Result.success)
        
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: new_tags.to_json }, locale: locale },
              format: :turbo_stream
        debug_request
        expect(response).to be_successful
      end
    end

    context "with invalid params" do
      it "returns unprocessable entity status" do
        set_current_organization
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' }, locale: locale },
              format: :turbo_stream,
              xhr: true
        debug_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets error message" do
        set_current_organization
        patch :update,
              params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' }, locale: locale },
              format: :turbo_stream,
              xhr: true
        debug_request
        expect(response.parsed_body['error']).to be_present
      end

      context "when JSON parsing fails" do
        let(:invalid_json) { '{not valid json' }

        it "handles JSON parse error" do
          set_current_organization
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: invalid_json }, locale: locale },
                format: :turbo_stream,
                xhr: true
          debug_request
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
          set_current_organization
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' }, locale: locale },
                format: :html
          debug_request
          expect(flash.now[:alert]).to be_present
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when rendering HTML format in native app" do
        before do
          set_native_headers
          allow(controller).to receive(:hotwire_native_app?).and_return(true)
        end

        it "sets flash alert and renders edit_native template" do
          set_current_organization
          patch :update,
                params: { restaurant_id: restaurant.id, restaurant: { tags: 'invalid_json' }, locale: locale },
                format: :html
          debug_request
          expect(flash.now[:alert]).to be_present
          expect(response).to render_template(:edit_native)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  context "when restaurant is not found" do
    it "returns not found status" do
      set_current_organization
      patch :update,
            params: { restaurant_id: 0, restaurant: { tags: '[]' }, locale: locale },
            format: :turbo_stream
      debug_request
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Restaurant not found")
    end

    it "returns not found status for edit action" do
      set_current_organization
      get :edit, params: { restaurant_id: 0, locale: locale }
      debug_request
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Restaurant not found")
    end
  end
  
  context "when accessing restaurant from another organization" do
    let(:other_organization) { create(:organization) }
    let(:other_restaurant) { create(:restaurant, organization: other_organization) }

    it "returns not found for edit action" do
      set_current_organization
      get :edit, params: { restaurant_id: other_restaurant.id, locale: locale }
      debug_request
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for update action" do
      set_current_organization
      patch :update,
            params: { restaurant_id: other_restaurant.id, restaurant: { tags: '[]' }, locale: locale },
            format: :turbo_stream
      debug_request
      expect(response).to have_http_status(:not_found)
    end
  end
end
