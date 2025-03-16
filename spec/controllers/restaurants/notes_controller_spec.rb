require 'rails_helper'

RSpec.describe Restaurants::NotesController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }

  before do
    sign_in user
  end

  # Helper method to simulate native app
  def set_native_headers
    @request.headers["HTTP_USER_AGENT"] = "Turbo Native iOS"
    puts "\n=== Debug Headers ==="
    puts "User Agent: #{@request.headers['HTTP_USER_AGENT']}"
    puts "Native App?: #{@controller&.send(:hotwire_native_app?)}"
    puts "===================\n"
  end

  describe "GET #edit" do
    it "renders edit template for web" do
      get :edit, params: { restaurant_id: restaurant.id }
      expect(response).to render_template("restaurants/notes/edit")
    end

    it "renders edit_native template for native app" do
      set_native_headers
      get :edit, params: { restaurant_id: restaurant.id }

      puts "\n=== Debug Response ==="
      puts "Response Status: #{response.status}"
      puts "Content Type: #{response.content_type}"
      puts "Headers in Controller: #{@controller.request.headers['HTTP_TURBO_NATIVE']}"
      puts "Native App?: #{@controller.send(:hotwire_native_app?)}"
      puts "===================\n"

      expect(response).to render_template("restaurants/notes/edit_native")
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_notes) { "Updated restaurant notes" }

      it "updates the restaurant notes" do
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes }
        }
        expect(restaurant.reload.notes).to eq(new_notes)
      end

      it "returns success for web requests" do
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes }
        }
        expect(response).to be_successful
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end

      it "redirects for native app requests" do
        set_native_headers
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: new_notes }
        }
        expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: nil))
      end
    end

    context "with invalid params" do
      before do
        allow_any_instance_of(Restaurant).to receive(:update).and_return(false)
      end

      it "returns unprocessable_entity for web requests" do
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: "" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("restaurants/notes/edit")
      end

      it "renders edit_native for native app requests" do
        set_native_headers
        patch :update, params: {
          restaurant_id: restaurant.id,
          restaurant: { notes: "" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("restaurants/notes/edit_native")
      end
    end

    context "with unauthorized access" do
      let(:other_user) { create(:user) }
      let(:other_restaurant) { create(:restaurant, user: other_user) }

      it "returns not found" do
        patch :update, params: {
          restaurant_id: other_restaurant.id,
          restaurant: { notes: "Unauthorized update" }
        }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
