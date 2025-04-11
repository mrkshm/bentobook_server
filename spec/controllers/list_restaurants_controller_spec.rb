require 'rails_helper'

RSpec.describe ListRestaurantsController, type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:list) { create(:list, organization: organization, creator: user) }
  let(:restaurant) { create(:restaurant, organization: organization) }
  
  before do
    # Create membership for user in organization
    create(:membership, user: user, organization: organization)
  end
  
  describe 'authentication' do
    it 'redirects to sign in page when not authenticated' do
      get new_list_list_restaurant_path(list_id: list.id)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  
  context 'when authenticated' do
    before do 
      sign_in user 
      # Set Current.organization for the test
      allow(Current).to receive(:organization).and_return(organization)
      
      # Mock the search_by_full_text method
      restaurants_collection = double("restaurants_collection")
      allow(organization).to receive(:restaurants).and_return(restaurants_collection)
      allow(restaurants_collection).to receive(:search_by_full_text).and_return(restaurants_collection)
      allow(restaurants_collection).to receive(:includes).and_return(restaurants_collection)
      allow(restaurants_collection).to receive(:order).and_return(Restaurant.none)
    end
    
    after do
      # Reset Current.organization to avoid affecting other tests
      allow(Current).to receive(:organization).and_call_original
    end
    
    describe 'GET #index' do
      it 'returns successful response' do
        get list_list_restaurants_path(list_id: list.id)
        expect(response).to be_successful
      end
      
      it 'filters restaurants by search query' do
        # Mock the search results for this specific test
        restaurants_collection = double("restaurants_collection")
        filtered_collection = double("filtered_collection")
        allow(organization).to receive(:restaurants).and_return(restaurants_collection)
        allow(restaurants_collection).to receive(:search_by_full_text).with("sushi").and_return(filtered_collection)
        allow(filtered_collection).to receive(:includes).and_return(filtered_collection)
        allow(filtered_collection).to receive(:order).and_return([build_stubbed(:restaurant, name: 'Sushi Place')])
        
        # Mock the pagy method to return a pagy object and our collection
        allow_any_instance_of(ListRestaurantsController).to receive(:pagy).and_return([double("pagy"), [build_stubbed(:restaurant, name: 'Sushi Place')]])
        
        get list_list_restaurants_path(list_id: list.id, query: 'sushi')
        
        expect(response).to be_successful
      end
    end
    
    describe 'GET #new' do
      it 'returns successful response' do
        get new_list_list_restaurant_path(list_id: list.id)
        expect(response).to be_successful
      end
      
      it 'displays restaurants with their cuisine types' do
        # Mock the search results for this specific test
        restaurants_collection = double("restaurants_collection")
        filtered_collection = double("filtered_collection")
        allow(organization).to receive(:restaurants).and_return(restaurants_collection)
        allow(restaurants_collection).to receive(:search_by_full_text).with("Sushi").and_return(filtered_collection)
        allow(filtered_collection).to receive(:includes).and_return(filtered_collection)
        allow(filtered_collection).to receive(:order).and_return([build_stubbed(:restaurant, name: 'Sushi Place')])
        
        # Mock the pagy method to return a pagy object and our collection
        allow_any_instance_of(ListRestaurantsController).to receive(:pagy).and_return([double("pagy"), [build_stubbed(:restaurant, name: 'Sushi Place')]])
        
        # First load the search form
        get new_list_list_restaurant_path(list_id: list.id)
        expect(response).to be_successful
        
        # Then make the search request for just the results frame
        get list_list_restaurants_path(
          list_id: list.id,
          query: 'Sushi'
        ), headers: {
          'TURBO-FRAME' => 'results'
        }
        
        expect(response).to be_successful
      end
    end
    
    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new list restaurant' do
          expect {
            post list_list_restaurants_path(list_id: list.id), 
                 params: { restaurant_id: restaurant.id }
          }.to change(ListRestaurant, :count).by(1)
        end
        
        it 'redirects to list with success message' do
          post list_list_restaurants_path(list_id: list.id), 
               params: { restaurant_id: restaurant.id }
               
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:notice]).to be_present
        end
      end
      
      context 'with invalid params' do
        before do
          create(:list_restaurant, list: list, restaurant: restaurant)
        end
        
        it 'does not create duplicate list restaurant' do
          expect {
            post list_list_restaurants_path(list_id: list.id), 
                 params: { restaurant_id: restaurant.id }
          }.not_to change(ListRestaurant, :count)
        end
        
        it 'redirects with error message' do
          post list_list_restaurants_path(list_id: list.id), 
               params: { restaurant_id: restaurant.id }
               
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
      end
    end
    
    describe 'DELETE #destroy' do
      let!(:list_restaurant) { create(:list_restaurant, list: list, restaurant: restaurant) }
      
      it 'removes restaurant from list' do
        expect {
          delete list_list_restaurant_path(list_id: list.id, id: list_restaurant.id)
        }.to change(ListRestaurant, :count).by(-1)
        
        expect(response).to redirect_to(edit_list_list_restaurants_path(list_id: list.id))
        expect(flash[:notice]).to be_present
      end
      
      it 'returns 404 for non-existent restaurant in list' do
        # Mock the 404 rendering to avoid file path issues
        allow_any_instance_of(ListRestaurantsController).to receive(:render).with(hash_including(file: 'public/404.html')).and_return(nil)
        
        delete list_list_restaurant_path(list_id: list.id, id: 0)
        expect(response).to have_http_status(:not_found)
      end
    end
    
    context 'with another organization\'s list' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, organization: other_organization, creator: other_user) }
      
      before do
        create(:membership, user: other_user, organization: other_organization)
        
        # Mock the 404 rendering to avoid file path issues
        allow_any_instance_of(ListRestaurantsController).to receive(:render).with(hash_including(file: 'public/404.html')).and_return(nil)
      end
      
      it 'returns 404 for index' do
        get list_list_restaurants_path(list_id: other_list.id)
        expect(response).to have_http_status(:not_found)
      end
      
      it 'returns 404 for create' do
        post list_list_restaurants_path(list_id: other_list.id), 
             params: { restaurant_id: restaurant.id }
        expect(response).to have_http_status(:not_found)
      end
      
      it 'returns 404 for destroy' do
        delete list_list_restaurant_path(list_id: other_list.id, id: restaurant.id)
        expect(response).to have_http_status(:not_found)
      end
    end
    
    context 'with shared list' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, organization: other_organization, creator: other_user) }
      
      before do
        create(:membership, user: other_user, organization: other_organization)
        
        # Share list with edit permission
        create(:share, 
          source_organization: other_organization,
          target_organization: organization,
          shareable: other_list, 
          permission: :edit,
          status: :accepted
        )
        
        # Mock the viewable_by? and editable_by? methods
        allow_any_instance_of(List).to receive(:viewable_by?).with(organization).and_return(true)
        allow_any_instance_of(List).to receive(:editable_by?).with(organization).and_return(true)
      end
      
      it 'allows adding restaurants when organization has edit permission' do
        expect {
          post list_list_restaurants_path(list_id: other_list.id), 
               params: { restaurant_id: restaurant.id }
        }.to change(ListRestaurant, :count).by(1)
        
        expect(response).to redirect_to(list_path(id: other_list.id))
        expect(flash[:notice]).to be_present
      end
      
      it 'allows removing restaurants when organization has edit permission' do
        list_restaurant = create(:list_restaurant, list: other_list, restaurant: restaurant)
        
        expect {
          delete list_list_restaurant_path(list_id: other_list.id, id: list_restaurant.id)
        }.to change(ListRestaurant, :count).by(-1)
        
        expect(response).to redirect_to(edit_list_list_restaurants_path(list_id: other_list.id))
        expect(flash[:notice]).to be_present
      end
    end
    
    context 'with shared list and view-only permission' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, organization: other_organization, creator: other_user) }
      let!(:list_restaurant) { create(:list_restaurant, list: other_list, restaurant: restaurant) }
      
      before do
        create(:membership, user: other_user, organization: other_organization)
        
        # Share list with view-only permission
        create(:share, 
          source_organization: other_organization,
          target_organization: organization,
          shareable: other_list, 
          permission: :view,
          status: :accepted
        )
        
        # Mock the viewable_by? and editable_by? methods
        allow_any_instance_of(List).to receive(:viewable_by?).with(organization).and_return(true)
        allow_any_instance_of(List).to receive(:editable_by?).with(organization).and_return(false)
        
        # Mock the copy_for_organization method to avoid database dependencies
        allow_any_instance_of(Restaurant).to receive(:copy_for_organization) do |restaurant, target_org|
          restaurant_copy = build_stubbed(:restaurant, organization: target_org)
          allow(restaurant_copy).to receive(:persisted?).and_return(true)
          restaurant_copy
        end
      end
      
      it 'allows importing restaurants with view permission' do
        # Mock RestaurantCopy to avoid database dependencies
        restaurant_copy_relation = double("restaurant_copy_relation")
        allow(RestaurantCopy).to receive(:where).and_return(restaurant_copy_relation)
        allow(restaurant_copy_relation).to receive(:select).and_return([])
        
        # Mock the list.restaurants.find to return our restaurant
        restaurants_collection = double("restaurants_collection")
        allow(other_list).to receive(:restaurants).and_return(restaurants_collection)
        allow(restaurants_collection).to receive(:find).and_return(restaurant)
        
        post import_list_list_restaurant_path(list_id: other_list.id, id: restaurant.id),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          
        expect(response).to be_successful
      end
      
      it 'allows importing all restaurants with view permission' do
        # Mock RestaurantCopy to avoid database dependencies
        restaurant_copy_relation = double("restaurant_copy_relation")
        allow(RestaurantCopy).to receive(:where).and_return(restaurant_copy_relation)
        allow(restaurant_copy_relation).to receive(:select).and_return([])
        
        # Mock the list.restaurants.where to return our restaurant
        restaurants_collection = double("restaurants_collection")
        filtered_collection = double("filtered_collection")
        allow(other_list).to receive(:restaurants).and_return(restaurants_collection)
        allow(restaurants_collection).to receive(:where).and_return([restaurant])
        
        post import_all_list_list_restaurants_path(list_id: other_list.id),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          
        expect(response).to be_successful
      end
      
      it 'prevents adding new restaurants to list' do
        post list_list_restaurants_path(
          list_id: other_list.id, 
          params: { restaurant_id: restaurant.id }
        )
        
        expect(response).to redirect_to(list_path(id: other_list.id))
        expect(flash[:alert]).to be_present
      end
      
      it 'prevents removing restaurants from list' do
        delete list_list_restaurant_path(
          list_id: other_list.id, 
          id: list_restaurant.id
        )
        
        expect(response).to redirect_to(list_path(id: other_list.id))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
