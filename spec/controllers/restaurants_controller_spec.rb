require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:italian_cuisine) { create(:cuisine_type, name: 'italian') }
  let(:google_restaurant) { create(:google_restaurant) }
  let(:valid_attributes) do
    attributes_for(:restaurant, :for_create).merge(
      cuisine_type_name: "italian",
      google_restaurant_attributes: {
        google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
        name: "Test Restaurant",
        address: "123 Test St",
        city: "Test City",
        latitude: 40.7128,
        longitude: -74.0060
      }
    )
  end
  let(:invalid_attributes) { { rating: 'dongus' } }  # or some other invalid attribute

  before { sign_in user }

  describe "GET #index" do
    it "assigns @restaurants" do
      get :index
      expect(assigns(:restaurants)).to eq([ restaurant ])
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

    context "when performed? is true" do
      before do
        allow(controller).to receive(:performed?).and_return(true)
      end

      it "returns early without executing the rest of the action" do
        expect(controller).not_to receive(:pagy)
        expect(RestaurantQuery).not_to receive(:new)  # Also shouldn't create a query
        expect(controller).not_to receive(:search_params)  # Shouldn't process search params

        get :index

        # Verify that none of the instance variables were set
        expect(assigns(:restaurants)).to be_nil
        expect(assigns(:pagy)).to be_nil
        expect(assigns(:tags)).to be_nil
      end
    end

    context "items_per_page parameter" do
      it "uses the provided per_page value when positive" do
        get :index, params: { per_page: 5 }
        expect(assigns(:pagy).vars[:items]).to eq(5)
      end

      it "uses default value (10) when per_page is zero" do
        get :index, params: { per_page: 0 }
        expect(assigns(:pagy).vars[:items]).to eq(10)
      end

      it "uses default value (10) when per_page is negative" do
        get :index, params: { per_page: -5 }
        expect(assigns(:pagy).vars[:items]).to eq(10)
      end

      it "uses default value (10) when per_page is not provided" do
        get :index
        expect(assigns(:pagy).vars[:items]).to eq(10)
      end
    end

    context "performed? check" do
      it "returns early when performed? is true" do
        allow(controller).to receive(:performed?).and_return(true)

        get :index

        expect(assigns(:restaurants)).to be_nil
        expect(assigns(:pagy)).to be_nil
        expect(assigns(:tags)).to be_nil
        expect(response.body).to be_blank
      end

      it "continues processing when performed? is false" do
        restaurant # ensure restaurant exists
        allow(controller).to receive(:performed?).and_return(false)

        get :index

        expect(assigns(:restaurants)).to eq([ restaurant ])
        expect(assigns(:pagy)).to be_present
        expect(assigns(:tags)).to eq(ActsAsTaggableOn::Tag.most_used(10))
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
    it "renders the search form" do
      get :new
      expect(response).to render_template(:new)
    end

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

  describe "POST #new_confirm" do
    let(:place_params) do
      {
        google_place_id: "test_place_id",
        name: "Test Restaurant",
        formatted_address: "123 Test St",
        latitude: 40.7128,
        longitude: -74.0060
      }
    end

    it "finds or creates a google restaurant" do
      expect(Restaurants::GooglePlaceImportService).to receive(:find_or_create)
        .with(place_params.stringify_keys)
        .and_return(google_restaurant)

      post :new_confirm, params: { place: place_params }, format: :turbo_stream
    end

    it "updates the restaurant search and form" do
      allow(Restaurants::GooglePlaceImportService).to receive(:find_or_create)
        .and_return(google_restaurant)

      post :new_confirm, params: { place: place_params }, format: :turbo_stream

      expect(response.body).to include('turbo-stream action="update" target="restaurant_search"')
      expect(response.body).to include('turbo-stream action="update" target="restaurant_form"')
    end
  end

  describe "POST #create" do
    before do
      italian_cuisine # ensure cuisine type exists
    end

    let(:google_restaurant) { create(:google_restaurant) }

    context "with valid params" do
      it "creates a restaurant using StubCreatorService" do
        expect(Restaurants::StubCreatorService).to receive(:create)
          .with(user: user, google_restaurant: google_restaurant)
          .and_return([ restaurant, :new ])

        post :create, params: { restaurant: { google_restaurant_id: google_restaurant.id } }
      end

      it "redirects to the created restaurant with success message" do
        allow(Restaurants::StubCreatorService).to receive(:create)
          .and_return([ restaurant, :new ])

        post :create, params: { restaurant: { google_restaurant_id: google_restaurant.id } }

        expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: nil))
        expect(flash[:success]).to eq(I18n.t("restaurants.created"))
      end

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

      it "creates or finds the correct cuisine type" do
        post :create, params: { restaurant: valid_attributes }
        expect(Restaurant.last.cuisine_type.name).to eq("italian")
      end

      it "redirects to the created restaurant" do
        post :create, params: { restaurant: valid_attributes }
        expect(response).to redirect_to(action: :show, id: Restaurant.last.id)
      end

      it "handles image upload successfully" do
        image = fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg')
        valid_params = valid_attributes.merge(images: [ image ])

        expect(ImageProcessorService).to receive(:new).and_return(
          instance_double(ImageProcessorService, process: ImageProcessorService::Result.new(success: true))
        )

        post :create, params: { restaurant: valid_params }
        expect(response).to redirect_to(action: :show, id: Restaurant.last.id)
      end
    end

    context "when restaurant already exists" do
      it "redirects with info message" do
        allow(Restaurants::StubCreatorService).to receive(:create)
          .and_return([ restaurant, :existing ])

        post :create, params: { restaurant: { google_restaurant_id: google_restaurant.id } }

        expect(response).to redirect_to(restaurant_path(id: restaurant.id, locale: nil))
        expect(flash[:info]).to eq(I18n.t("restaurants.already_exists"))
      end
    end

    context "when google restaurant is not found" do
      it "redirects to new with error" do
        post :create, params: { restaurant: { google_restaurant_id: 0 } }

        expect(response).to redirect_to(new_restaurant_path)
        expect(flash[:error]).to eq(I18n.t("restaurants.errors.google_restaurant_not_found"))
      end
    end

    context "with invalid cuisine type" do
      let(:valid_google_restaurant_attributes) do
        {
          google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
          name: "Test Restaurant",
          address: "123 Test St",
          city: "Test City",
          latitude: 40.7128,
          longitude: -74.0060
        }
      end

      it "renders new template with error" do
        post :create, params: {
          restaurant: valid_attributes.merge(
            cuisine_type_name: "invalid_cuisine",
            google_restaurant_attributes: valid_google_restaurant_attributes
          )
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Invalid cuisine type: invalid_cuisine. Available types: italian")
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) do
        {
          name: "",  # Invalid because name is blank
          google_restaurant_attributes: {
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
            name: "Test Restaurant",
            address: "123 Test St",
            city: "Test City",
            latitude: 40.7128,
            longitude: -74.0060
          }
        }
      end

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

    context "when a StandardError occurs" do
      let(:error_message) { "Something went wrong" }

      it "logs the error message" do
        test_restaurant = build(:restaurant, user: user)

        allow(controller).to receive(:build_restaurant) do
          controller.instance_variable_set(:@restaurant, test_restaurant)
          raise StandardError.new(error_message)
        end

        expect(Rails.logger).to receive(:error).with("Error creating restaurant: Something went wrong")

        post :create, params: { restaurant: valid_attributes }
      end

      it "destroys the restaurant if it was persisted" do
        # Create a persisted restaurant
        test_restaurant = create(:restaurant, user: user)
        test_restaurant.errors.add(:base, error_message)

        # Expect destroy to be called
        expect(test_restaurant).to receive(:destroy)

        allow(controller).to receive(:build_restaurant) do
          controller.instance_variable_set(:@restaurant, test_restaurant)
          raise StandardError.new(error_message)
        end

        post :create, params: { restaurant: valid_attributes }
      end

      it "doesn't destroy the restaurant if it wasn't persisted" do
        # Create a non-persisted restaurant
        test_restaurant = build(:restaurant, user: user)
        test_restaurant.errors.add(:base, error_message)

        # Expect destroy NOT to be called
        expect(test_restaurant).not_to receive(:destroy)

        allow(controller).to receive(:build_restaurant) do
          controller.instance_variable_set(:@restaurant, test_restaurant)
          raise StandardError.new(error_message)
        end

        post :create, params: { restaurant: valid_attributes }
      end

      it "handles nil @restaurant" do
        allow(controller).to receive(:build_restaurant) do
          # Initialize an empty restaurant to avoid nil errors in handle_failed_save
          controller.instance_variable_set(:@restaurant, Restaurant.new)
          raise StandardError.new(error_message)
        end

        expect(Rails.logger).to receive(:error).with("Error creating restaurant: Something went wrong")

        post :create, params: { restaurant: valid_attributes }

        expect(flash[:alert]).to eq(error_message)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end

      it "handles complete failure with nil @restaurant" do
        allow(controller).to receive(:build_restaurant).and_raise(StandardError.new(error_message))

        expect(Rails.logger).to receive(:error).with("Error creating restaurant: Something went wrong")

        post :create, params: { restaurant: valid_attributes }

        expect(flash[:alert]).to eq(error_message)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(assigns(:cuisine_types)).to eq(CuisineType.all)
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
        expect(response).to redirect_to(restaurant_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) do
        {
          price_level: "not_a_number",
          cuisine_type_name: "italian"
        }
      end

      it "re-renders the 'edit' template" do
        create(:cuisine_type, name: 'italian')

        # Mock the RestaurantUpdater service
        updater = instance_double(RestaurantUpdater)
        allow(RestaurantUpdater).to receive(:new).and_return(updater)

        # Make update add an error to the @restaurant instance variable
        allow(updater).to receive(:update) do
          controller.instance_variable_get(:@restaurant).errors.add(:price_level, :not_a_number)
          false
        end

        put :update, params: { id: restaurant.to_param, restaurant: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq('Price level is not a number')
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow_any_instance_of(Restaurant).to receive(:update).and_raise(StandardError.new("Unexpected error"))
      end

      it "logs the error and handles the failure" do
        expect(Rails.logger).to receive(:error).with(/Update error:/)

        put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to eq("Cuisine type 'italian' is not valid")
        expect(response).to render_template(:edit)
      end
    end

    context "when a StandardError occurs during update" do
      let(:error_message) { "Test error message" }

      before do
        allow_any_instance_of(RestaurantUpdater).to receive(:update).and_raise(StandardError.new(error_message))
      end

      it "handles the error correctly" do
        expect(Rails.logger).to receive(:error).with("Error updating restaurant #{restaurant.id}: #{error_message}")

        begin
          put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
        rescue ActiveRecord::Rollback
          # Expected to raise Rollback, now check our expectations
          expect(assigns(:cuisine_types)).to eq(CuisineType.all)
          expect(flash[:alert]).to eq("Error updating the restaurant: #{error_message}")
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it "raises ActiveRecord::Rollback" do
        expect {
          put :update, params: { id: restaurant.to_param, restaurant: valid_attributes }
        }.to raise_error(ActiveRecord::Rollback)
      end
    end

    context "when image processing fails" do
      let(:failed_result) { double(success?: false, error: "Image processing error message") }
      let(:image_file) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
      let(:update_params) { valid_attributes.merge(images: [ image_file ]) }

      before do
        allow_any_instance_of(RestaurantUpdater).to receive(:update).and_return(true)
        allow(ImageProcessorService).to receive(:new)
          .and_return(double(process: failed_result))
      end

      it "raises ActiveRecord::Rollback and sets flash alert" do
        expect {
          put :update, params: {
            id: restaurant.to_param,
            restaurant: update_params
          }
        }.to raise_error(ActiveRecord::Rollback)

        expect(flash[:alert]).to eq("Error updating the restaurant: Image processing failed")
      end

      it "prevents the update from being saved" do
        begin
          put :update, params: {
            id: restaurant.to_param,
            restaurant: update_params
          }
        rescue ActiveRecord::Rollback
          # Expected
        end

        restaurant.reload
        expect(restaurant.images).to be_empty
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
      ActionController::Parameters.new(
        restaurant: {
          name: "Test Restaurant",
          address: "123 Test St",
          cuisine_type_name: "italian"
        }
      ).require(:restaurant).permit!
    end

    before do
      create(:cuisine_type, name: "italian") # Ensure the cuisine type exists
      allow(controller).to receive(:restaurant_params).and_return(restaurant_params)
    end

    it "builds a new restaurant with the given params" do
      restaurant = controller.send(:build_restaurant)

      expect(restaurant).to be_a_new(Restaurant)
      expect(restaurant.name).to eq("Test Restaurant")
      expect(restaurant.address).to eq("123 Test St")
      expect(restaurant.cuisine_type.name).to eq("italian")
    end

    it "uses an existing cuisine type if it exists" do
      existing_cuisine = CuisineType.find_or_create_by(name: "italian")
      expect {
        restaurant = controller.send(:build_restaurant)
        expect(restaurant.cuisine_type).to eq(existing_cuisine)
      }.not_to change(CuisineType, :count)
    end
  end
end
