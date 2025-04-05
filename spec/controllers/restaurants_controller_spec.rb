require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  let(:italian_cuisine) { create(:cuisine_type, name: 'italian') }
  let(:google_restaurant) { create(:google_restaurant, name: "Test Restaurant", address: "123 Test St") }
  let(:valid_attributes) do
    {
      name: "Test Restaurant",
      address: "123 Test St",
      cuisine_type_id: italian_cuisine.id,
      rating: 4,
      price_level: 2,
      google_restaurant_id: google_restaurant.id
    }
  end
  let(:invalid_attributes) do
    {
      name: "", # invalid because name is required
      google_restaurant_id: google_restaurant.id # keep the same to avoid unique constraint
    }
  end
  let(:restaurant) { create(:restaurant, organization: @shared_organization) }

  before(:all) do
    # Create these once for all tests
    @shared_organization = create(:organization)
    @shared_user = create(:user)
    create(:membership, user: @shared_user, organization: @shared_organization)
  end

  before(:each) do
    sign_in @shared_user
    Current.user = @shared_user
    Current.organization = @shared_organization
  end

  after(:each) do
    Current.reset
  end

  after(:all) do
    # Clean up shared resources
    @shared_user.destroy  # Destroy user first since it has the membership
    @shared_organization.destroy
  end

  describe "GET #index" do
    before do
      create(:restaurant, organization: @shared_organization) # ensure restaurant exists
    end

    it "assigns @restaurants" do
      get :index
      expect(assigns(:restaurants)).to eq([ Restaurant.last ])
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
    end

    context "items_per_page parameter" do
      it "uses the provided per_page value when positive" do
        get :index, params: { per_page: 5 }
        expect(assigns(:pagy).vars[:items]).to eq(5)
      end

      it "uses default value (12) when per_page is zero" do
        get :index, params: { per_page: 0 }
        expect(assigns(:pagy).vars[:items]).to eq(12)
      end

      it "uses default value (12) when per_page is negative" do
        get :index, params: { per_page: -5 }
        expect(assigns(:pagy).vars[:items]).to eq(12)
      end

      it "uses default value (12) when per_page is not provided" do
        get :index
        expect(assigns(:pagy).vars[:items]).to eq(12)
      end
    end
  end

  describe "GET #show" do
    let!(:restaurant) { create(:restaurant, organization: @shared_organization) } # ensure restaurant exists

    it "assigns the requested restaurant as @restaurant" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns @tags" do
      restaurant.tag_list.add("test_tag")
      restaurant.save
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:tags)).to eq(restaurant.tags)
    end

    it "assigns @all_tags" do
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:all_tags)).to eq(ActsAsTaggableOn::Tag.all)
    end

    it "assigns @visits" do
      visit = create(:visit, restaurant: restaurant, organization: @shared_organization)
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:visits)).to eq([ visit ])
    end

    it "assigns @lists" do
      list = create(:list, organization: @shared_organization)
      create(:list_restaurant, list: list, restaurant: restaurant)
      get :show, params: { id: restaurant.to_param }
      expect(assigns(:lists)).to include(list)
    end
  end

  describe "GET #edit" do
    let!(:restaurant) { create(:restaurant, organization: @shared_organization) } # ensure restaurant exists

    it "assigns the requested restaurant as @restaurant" do
      get :edit, params: { id: restaurant.to_param }
      expect(assigns(:restaurant)).to eq(restaurant)
    end

    it "assigns @cuisine_types" do
      get :edit, params: { id: restaurant.to_param }
      expect(assigns(:cuisine_types)).to eq(CuisineType.all)
    end
  end

  describe "POST #create" do
    before { italian_cuisine } # ensure cuisine type exists

    context "with valid params" do
      it "creates a new restaurant" do
        expect {
          post :create, params: { restaurant: valid_attributes }
        }.to change(Restaurant, :count).by(1)
      end

      it "assigns organization to the new restaurant" do
        post :create, params: { restaurant: valid_attributes }
        expect(Restaurant.last.organization).to eq(@shared_organization)
      end

      it "creates or finds the correct cuisine type" do
        post :create, params: { restaurant: valid_attributes }
        expect(Restaurant.last.cuisine_type).to eq(italian_cuisine)
      end

      it "redirects to the created restaurant" do
        post :create, params: { restaurant: valid_attributes }
        expect(response).to redirect_to(restaurant_path(Restaurant.last, locale: :en))
      end
    end

    context "with invalid params" do
      before do
        @request.env["HTTP_ACCEPT"] = "text/html"
        # Ensure validation fails
        allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
        allow_any_instance_of(Restaurant).to receive(:errors).and_return(
          double(full_messages: ["Name can't be blank"])
        )
      end

      it "re-renders the 'new' template" do
        puts "\n=== Create Test Debug ==="
        post :create, params: { restaurant: invalid_attributes }
        
        puts "Response status: #{response.status}"
        puts "Response content type: #{response.content_type}"
        puts "Flash: #{flash.inspect}"
        puts "Restaurant errors: #{assigns(:restaurant).errors.full_messages}"
        puts "=== End Create Test Debug ==="

        expect(assigns(:restaurant)).to be_a_new(Restaurant)
        expect(assigns(:cuisine_types)).to be_present
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PUT #update" do
    let!(:restaurant) { create(:restaurant, organization: @shared_organization) }

    context "with valid params" do
      let(:new_attributes) { { name: "Updated Name" } }

      it "updates the requested restaurant" do
        put :update, params: { id: restaurant.to_param, restaurant: new_attributes }
        restaurant.reload
        expect(restaurant.name).to eq("Updated Name")
      end

      it "redirects to the restaurant" do
        put :update, params: { id: restaurant.to_param, restaurant: new_attributes }
        expect(response).to redirect_to(restaurant_path(restaurant))
      end
    end

    context "with invalid params" do
      before do
        @request.env["HTTP_ACCEPT"] = "text/html"
        # Ensure name is required
        allow_any_instance_of(Restaurant).to receive(:valid?).and_return(false)
        allow_any_instance_of(Restaurant).to receive(:errors).and_return(
          double(full_messages: ["Name can't be blank"])
        )
      end

      it "re-renders the 'edit' template" do
        puts "\n=== Test Debug ==="
        puts "Restaurant before update: #{restaurant.inspect}"
        puts "Organization: #{@shared_organization.inspect}"
        
        expect(restaurant).to be_persisted
        expect(restaurant.organization).to eq(@shared_organization)
        
        put :update, params: { id: restaurant.to_param, restaurant: invalid_attributes }
        
        puts "\nAfter update:"
        puts "Response status: #{response.status}"
        puts "Response content type: #{response.content_type}"
        puts "Flash: #{flash.inspect}"
        puts "Flash.now: #{flash.now.inspect}"
        puts "Restaurant errors: #{assigns(:restaurant).errors.full_messages}"
        puts "=== End Test Debug ==="
        
        expect(assigns(:restaurant)).to eq(restaurant)
        expect(assigns(:cuisine_types)).to be_present
        expect(response.content_type).to include("text/html")
        expect(flash.now[:alert]).to be_present
        expect(response).to render_template(:edit)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:restaurant) { create(:restaurant, organization: @shared_organization) } # ensure restaurant exists

    it "destroys the requested restaurant" do
      expect {
        delete :destroy, params: { id: restaurant.to_param }
      }.to change(Restaurant, :count).by(-1)
    end

    it "redirects to the restaurants list" do
      delete :destroy, params: { id: restaurant.to_param }
      expect(response).to redirect_to(restaurants_url)
    end
  end
end
