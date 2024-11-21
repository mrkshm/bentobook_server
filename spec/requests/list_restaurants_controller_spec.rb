require 'rails_helper'

RSpec.describe ListRestaurantsController, type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  let(:restaurant) { create(:restaurant) }
  
  describe 'authentication' do
    it 'returns unauthorized status when not authenticated' do
      get new_list_list_restaurant_path(list_id: list.id)
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('You need to sign in or sign up before continuing')
    end
  end
  
  context 'when authenticated' do
    before { sign_in user }
    
    describe 'GET #index' do
      it 'returns successful response' do
        get list_list_restaurants_path(list_id: list.id)
        expect(response).to be_successful
      end
      
      it 'filters restaurants by search query' do
        restaurant1 = create(:restaurant, name: 'Sushi Place')
        restaurant2 = create(:restaurant, name: 'Burger Joint')
        
        get list_list_restaurants_path(list_id: list.id, query: 'sushi')
        
        expect(response.body).to include('Sushi Place')
        expect(response.body).not_to include('Burger Joint')
      end
    end
    
    describe 'GET #new' do
      it 'returns successful response' do
        get new_list_list_restaurant_path(list_id: list.id)
        expect(response).to be_successful
      end
      
      it 'displays restaurants with their cuisine types' do
        cuisine = create(:cuisine_type, name: 'Japanese')
        restaurant = create(:restaurant, name: 'Sushi Place', cuisine_type: cuisine)
        
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
        
        expect(response.body).to include('Sushi Place')
        expect(response.body).to include('Japanese')
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
      end
      
      it 'redirects to edit page with success message' do
        delete list_list_restaurant_path(list_id: list.id, id: list_restaurant.id)
        
        expect(response).to redirect_to(edit_list_list_restaurants_path(list_id: list.id))
        expect(flash[:notice]).to be_present
      end
      
      it 'returns 404 for non-existent restaurant in list' do
        delete list_list_restaurant_path(list_id: list.id, id: 0)
        expect(response).to have_http_status(:not_found)
      end
    end
    
    context 'with another user\'s list' do
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, owner: other_user) }
      
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
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, owner: other_user) }
      
      before do
        create(:share, 
          creator: other_user, 
          recipient: user, 
          shareable: other_list, 
          permission: :edit,
          status: :accepted
        )
      end
      
      it 'allows adding restaurants when user has edit permission' do
        expect {
          post list_list_restaurants_path(list_id: other_list.id), 
               params: { restaurant_id: restaurant.id }
        }.to change(ListRestaurant, :count).by(1)
        
        expect(response).to redirect_to(list_path(id: other_list.id))
        expect(flash[:notice]).to be_present
      end
      
      it 'allows removing restaurants when user has edit permission' do
        list_restaurant = create(:list_restaurant, list: other_list, restaurant: restaurant)
        
        expect {
          delete list_list_restaurant_path(list_id: other_list.id, id: list_restaurant.id)
        }.to change(ListRestaurant, :count).by(-1)
        
        expect(response).to redirect_to(edit_list_list_restaurants_path(list_id: other_list.id))
        expect(flash[:notice]).to be_present
      end
    end
    
    context 'with shared list and view-only permission' do
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, owner: other_user) }
      let!(:list_restaurant) { create(:list_restaurant, list: other_list, restaurant: restaurant) }
      
      before do
        create(:share, 
          creator: other_user, 
          recipient: user, 
          shareable: other_list, 
          permission: :view,
          status: :accepted
        )
      end
      
      it 'allows importing restaurants with view permission' do
        expect {
          post import_list_list_restaurant_path(list_id: other_list.id, id: restaurant.id),
            headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        }.to change(RestaurantCopy, :count).by(1)
        
        expect(response).to be_successful
      end
      
      it 'allows importing all restaurants with view permission' do
        expect {
          post import_all_list_list_restaurants_path(list_id: other_list.id),
            headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        }.to change(RestaurantCopy, :count).by(1)
        
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
