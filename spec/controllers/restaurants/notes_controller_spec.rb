require 'rails_helper'

RSpec.describe Restaurants::NotesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  # Use create! to ensure the restaurant is created before the test runs
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

  # Helper method to simulate native app
  def set_native_headers
    @request.headers["HTTP_USER_AGENT"] = "Turbo Native iOS"
    puts "\n=== Debug Headers ==="
    puts "User Agent: #{@request.headers['HTTP_USER_AGENT']}"
    puts "Native App?: #{@controller&.send(:hotwire_native_app?)}"
    puts "==================="
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

  describe "GET #edit" do
    it "renders edit template" do
      # Verify the restaurant exists before making the request
      expect(Restaurant.exists?(restaurant.id)).to be true
      expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
      
      get :edit, params: { restaurant_id: restaurant.id, locale: locale }
      debug_request
      
      puts "\n=== Response Debug ==="
      puts "Response Status: #{response.status}"
      puts "Response Body: #{response.body}"
      puts "Controller: #{@controller.class.name}"
      puts "Action: #{@controller.action_name}"
      puts "Restaurant ID in params: #{controller.params[:restaurant_id]}"
      puts "==================="
      
      expect(response).to have_http_status(:success)
      expect(response).to render_template("restaurants/notes/edit")
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_notes) { "Updated restaurant notes" }

      it "updates the restaurant notes" do
        # Verify the restaurant exists before making the request
        expect(Restaurant.exists?(restaurant.id)).to be true
        expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
        
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes },
          locale: locale
        }
        debug_request
        
        puts "\n=== Update Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Restaurant ID: #{restaurant.id}"
        puts "Restaurant Organization: #{restaurant.organization_id}"
        puts "Current Organization: #{Current.organization&.id}"
        puts "Restaurant Notes Before: #{restaurant.notes}"
        puts "Restaurant Notes After: #{restaurant.reload.notes}"
        puts "==================="
        
        expect(restaurant.reload.notes).to eq(new_notes)
      end

      it "returns success for web requests" do
        # Verify the restaurant exists before making the request
        expect(Restaurant.exists?(restaurant.id)).to be true
        expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
        
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes },
          locale: locale
        }
        debug_request
        
        puts "\n=== Web Update Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Media Type: #{response.media_type}"
        puts "Controller: #{@controller.class.name}"
        puts "Action: #{@controller.action_name}"
        puts "==================="
        
        expect(response).to be_successful
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end

      it "redirects for native app requests" do
        # Verify the restaurant exists before making the request
        expect(Restaurant.exists?(restaurant.id)).to be true
        expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
        
        set_native_headers
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes },
          locale: locale
        }
        debug_request
        
        puts "\n=== Native Update Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Location Header: #{response.headers['Location']}"
        puts "Controller: #{@controller.class.name}"
        puts "Action: #{@controller.action_name}"
        puts "==================="
        
        expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: locale))
      end
    end

    context "with invalid params" do
      before do
        allow_any_instance_of(Restaurant).to receive(:update).and_return(false)
      end

      it "returns unprocessable_entity for web requests" do
        # Verify the restaurant exists before making the request
        expect(Restaurant.exists?(restaurant.id)).to be true
        expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
        
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: "" },
          locale: locale
        }
        debug_request
        
        puts "\n=== Invalid Update Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Controller: #{@controller.class.name}"
        puts "Action: #{@controller.action_name}"
        puts "==================="
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("restaurants/notes/edit")
      end

      it "returns unprocessable_entity for native app requests" do
        # Verify the restaurant exists before making the request
        expect(Restaurant.exists?(restaurant.id)).to be true
        expect(Current.organization.restaurants.exists?(restaurant.id)).to be true
        
        set_native_headers
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: "" },
          locale: locale
        }
        debug_request
        
        puts "\n=== Invalid Native Update Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Controller: #{@controller.class.name}"
        puts "Action: #{@controller.action_name}"
        puts "==================="
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("restaurants/notes/edit")
      end
    end

    context "with unauthorized access" do
      let(:other_organization) { create(:organization) }
      let(:other_restaurant) { create(:restaurant, organization: other_organization) }

      it "returns not found" do
        patch :update, params: {
          restaurant_id: other_restaurant.id,
          restaurant: { notes: "Unauthorized update" },
          locale: locale
        }
        debug_request
        
        puts "\n=== Unauthorized Debug ==="
        puts "Response Status: #{response.status}"
        puts "Response Body: #{response.body}"
        puts "Controller: #{@controller.class.name}"
        puts "Action: #{@controller.action_name}"
        puts "==================="
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
