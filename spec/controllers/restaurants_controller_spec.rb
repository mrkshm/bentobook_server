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
        expect(response).to redirect_to(Restaurant.last)
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
    it "adds a new tag to the restaurant" do
      expect {
        post :add_tag, params: { id: restaurant.to_param, tag: "newtag" }
      }.to change { restaurant.reload.tags.count }.by(1)
    end

    it "redirects to the restaurant page" do
      post :add_tag, params: { id: restaurant.to_param, tag: "newtag" }
      expect(response).to redirect_to(restaurant_path(restaurant))
    end
  end

  describe "DELETE #remove_tag" do
    before { restaurant.tag_list.add("existingtag"); restaurant.save }

    it "removes a tag from the restaurant" do
      expect {
        delete :remove_tag, params: { id: restaurant.to_param, tag: "existingtag" }
      }.to change { restaurant.reload.tags.count }.by(-1)
    end

    it "redirects to the restaurant page" do
      delete :remove_tag, params: { id: restaurant.to_param, tag: "existingtag" }
      expect(response).to redirect_to(restaurant_path(restaurant))
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
end
