require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:valid_attributes) do
    attributes_for(:restaurant, :for_create).merge(
      cuisine_type: "Italian",
      google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
      city: "Test City",
      latitude: 40.7128,
      longitude: -74.0060
    )
  end
  let(:invalid_attributes) { { name: '' } }  # or some other invalid attribute

  before { sign_in user }

  describe "GET #index" do
    it "assigns @restaurants" do
      get :index
      expect(assigns(:restaurants)).to eq([restaurant])
    end

    it "assigns @pagy" do
      get :index
      expect(assigns(:pagy)).to be_a(Pagy)
    end

    it "assigns @tags" do
      get :index
      expect(assigns(:tags)).to eq(ActsAsTaggableOn::Tag.most_used(10))
    end

    context "with invalid order parameters" do
      it "sets flash alert for invalid order_by" do
        get :index, params: { order_by: "invalid_field" }
        expect(flash.now[:alert]).to include('Invalid order_by parameter')
      end

      it "sets flash alert for invalid order_direction" do
        get :index, params: { order_direction: "invalid_direction" }
        expect(flash.now[:alert]).to include('Invalid order_direction parameter')
      end

      it "uses default order when order_by is invalid" do
        get :index, params: { order_by: "invalid_field" }
        expect(assigns(:restaurants).to_sql).to include("ORDER BY")
        expect(assigns(:restaurants).to_sql).to include(RestaurantQuery::DEFAULT_ORDER[:field])
      end

      it "uses default direction when order_direction is invalid" do
        get :index, params: { order_direction: "invalid_direction" }
        expect(controller.send(:parse_order_params)[:order_direction]).to eq(RestaurantQuery::DEFAULT_ORDER[:direction])
      end

      it "calls RestaurantQuery with default direction when order_direction is invalid" do
        expect(RestaurantQuery).to receive(:new).with(
          anything,
          hash_including(order_direction: RestaurantQuery::DEFAULT_ORDER[:direction])
        ).and_call_original
        get :index, params: { order_direction: "invalid_direction" }
      end

      it "parses order params correctly when order_direction is invalid" do
        get :index, params: { order_direction: "invalid_direction" }
        expect(controller.send(:parse_order_params)).to eq({
          order_by: RestaurantQuery::DEFAULT_ORDER[:field],
          order_direction: RestaurantQuery::DEFAULT_ORDER[:direction]
        })
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested restaurant as @restaurant" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns @tags" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:tags)).to eq(restaurant.tags)
    end

    it "assigns @all_tags" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:all_tags)).to eq(ActsAsTaggableOn::Tag.all)
    end

    it "assigns @visits" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:visits)).to eq(restaurant.visits)
    end
  end

  describe "GET #new" do
    it "assigns a new restaurant as @restaurant" do
      get :new
      expect(assigns(:restaurant)).to be_a_new(Restaurant)
    end

    it "builds a new google_restaurant for @restaurant" do
      get :new
      expect(assigns(:restaurant).google_restaurant).to be_a_new(GoogleRestaurant)
    end

    it "assigns @cuisine_types" do
      get :new
      expect(assigns(:cuisine_types)).to eq(CuisineType.all)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Restaurant" do
        expect {
          post :create, params: { restaurant: valid_attributes }
        }.to change(Restaurant, :count).by(1)
      end

      it "creates a new GoogleRestaurant" do
        expect {
          post :create, params: { restaurant: valid_attributes }
        }.to change(GoogleRestaurant, :count).by(1)
      end

      it "redirects to the created restaurant" do
        post :create, params: { restaurant: valid_attributes }
        expect(response).to redirect_to(restaurant_path(Restaurant.last))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved restaurant as @restaurant" do
        post :create, params: { restaurant: invalid_attributes }
        expect(assigns(:restaurant)).to be_a_new(Restaurant)
      end

      it "re-renders the 'new' template" do
        post :create, params: { restaurant: invalid_attributes }
        expect(response).to render_template("new")
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/Restaurant save failed/)
        post :create, params: { restaurant: valid_attributes }
      end

      it "renders the new template" do
        post :create, params: { restaurant: valid_attributes }
        expect(response).to render_template("new")
      end

      it "returns unprocessable_entity status" do
        post :create, params: { restaurant: valid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_cuisine_type) { create(:cuisine_type, name: "New Cuisine") }
      let(:new_attributes) { { name: "New Name", cuisine_type_id: new_cuisine_type.id } }

      it "updates the requested restaurant" do
        put :update, params: { id: restaurant.to_param, restaurant: new_attributes }
        restaurant.reload
        expect(restaurant.name).to eq("New Name")
        expect(restaurant.cuisine_type).to eq(new_cuisine_type)
      end

      it "redirects to the restaurant" do
        put :update, params: { id: restaurant.to_param, restaurant: new_attributes }
        expect(response).to redirect_to(restaurant)
      end
    end

    context "with invalid params" do
      it "assigns the restaurant as @restaurant" do
        put :update, params: { id: restaurant.to_param, restaurant: invalid_attributes }
        expect(assigns(:restaurant)).to eq(restaurant)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { id: restaurant.to_param, restaurant: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow_any_instance_of(RestaurantUpdater).to receive(:update).and_raise(StandardError.new("Unexpected error"))
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/Error updating restaurant/)
        put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
      end

      it "sets a flash alert" do
        put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
        expect(flash.now[:alert]).to match(/Error updating the restaurant/)
      end

      it "renders the edit template" do
        put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
        expect(response).to render_template("edit")
      end

      it "returns unprocessable_entity status" do
        put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested restaurant" do
      restaurant # ensure restaurant is created before the expect block
      expect {
        delete :destroy, params: { id: restaurant.to_param }
      }.to change(Restaurant, :count).by(-1)
    end

    it "redirects to the restaurants list" do
      delete :destroy, params: { id: restaurant.to_param }
      expect(response).to redirect_to(restaurants_url)
    end
  end

  describe "POST #add_tag" do
    context "when tag is successfully added" do
      it "redirects to the restaurant page with a success notice" do
        post :add_tag, params: { id: restaurant.to_param, tag: "newtag" }
        expect(response).to redirect_to(restaurant_path(restaurant))
        expect(flash[:notice]).to eq('Tag added successfully.')
      end
    end

    context "when tag addition fails" do
      before do
        allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
      end

      it "renders the show template with an alert" do
        post :add_tag, params: { id: restaurant.to_param, tag: "newtag" }
        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq('Failed to add tag.')
      end
    end

    context "when no tag is provided" do
      it "redirects to the restaurant page with an alert" do
        post :add_tag, params: { id: restaurant.to_param, tag: "" }
        expect(response).to redirect_to(restaurant_path(restaurant))
        expect(flash[:alert]).to eq('No tag provided.')
      end
    end
  end

  describe "DELETE #remove_tag" do
    before { restaurant.tag_list.add("existingtag"); restaurant.save }

    context "when tag is successfully removed" do
      it "redirects to the restaurant page with a success notice" do
        delete :remove_tag, params: { id: restaurant.to_param, tag: "existingtag" }
        expect(response).to redirect_to(restaurant_path(restaurant))
        expect(flash[:notice]).to eq('Tag removed successfully.')
      end
    end

    context "when tag removal fails" do
      before do
        allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
      end

      it "renders the show template with an alert" do
        delete :remove_tag, params: { id: restaurant.to_param, tag: "existingtag" }
        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq('Failed to remove tag.')
      end
    end

    context "when no tag is provided" do
      it "redirects to the restaurant page with an alert" do
        delete :remove_tag, params: { id: restaurant.to_param, tag: "" }
        expect(response).to redirect_to(restaurant_path(restaurant))
        expect(flash[:alert]).to eq('No tag provided.')
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested restaurant as @restaurant" do
      get :edit, params: { id: restaurant.to_param }
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns @cuisine_types" do
      get :edit, params: { id: restaurant.to_param }
      expect(assigns(:cuisine_types)).to eq(CuisineType.all)
    end
  end

  describe "#build_restaurant" do
    let(:restaurant_params) do
      {
        name: "Test Restaurant",
        address: "123 Test St",
        cuisine_type: "Italian"
      }
    end

    before do
      allow(controller).to receive(:restaurant_params).and_return(restaurant_params)
    end

    it "builds a new restaurant with the given params" do
      restaurant = controller.send(:build_restaurant)
      
      expect(restaurant).to be_a_new(Restaurant)
      expect(restaurant.name).to eq("Test Restaurant")
      expect(restaurant.address).to eq("123 Test St")
      expect(restaurant.cuisine_type.name).to eq("Italian")
    end

    it "creates a new cuisine type if it doesn't exist" do
      expect {
        controller.send(:build_restaurant)
      }.to change(CuisineType, :count).by(1)
    end

    it "uses an existing cuisine type if it exists" do
      existing_cuisine = create(:cuisine_type, name: "Italian")
      expect {
        restaurant = controller.send(:build_restaurant)
        expect(restaurant.cuisine_type).to eq(existing_cuisine)
      }.not_to change(CuisineType, :count)
    end
  end
end
