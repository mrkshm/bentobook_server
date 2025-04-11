require 'rails_helper'

RSpec.describe ListRestaurantsController, type: :controller do
  # Test authentication behavior
  describe 'authentication' do
    it 'redirects to sign in page when not authenticated' do
      get :new, params: { list_id: '1' }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  
  # Test basic behavior when user is authenticated
  describe 'basic functionality' do
    let(:user) { create(:user) }
    
    before do
      sign_in user
    end
    
    it 'handles non-existent lists with 404' do
      # This test does not require complex setup, just checks the 404 handling
      get :new, params: { list_id: 999999 }
      expect(response).to have_http_status(:not_found)
    end
  end
  
  # Test access control for other organizations' lists
  describe 'access control' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:other_user) { create(:user) }
    let(:other_organization) { create(:organization) }
    let(:other_list) { create(:list, organization: other_organization, creator: other_user) }
    
    before do
      create(:membership, user: user, organization: organization)
      create(:membership, user: other_user, organization: other_organization)
      sign_in user
      # Set Current context
      Current.user = user
      Current.organization = organization
    end
    
    after do
      Current.reset
    end
    
    it 'restricts access to lists from other organizations' do
      get :new, params: { list_id: other_list.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end