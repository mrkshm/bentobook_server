require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:other_organization) { create(:organization) }
  let(:other_user) { create(:user) }
  let!(:restaurant) { create(:restaurant, organization: organization) }
  let!(:visit) { create(:visit, organization: organization, restaurant: restaurant) }
  let!(:image) { create(:image, imageable: restaurant) }
  let(:locale) { 'en' }
  
  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    # Create membership for other user with other organization
    create(:membership, user: other_user, organization: other_organization)
    # Set Current.organization for the test
    Current.organization = organization
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

  # Helper to ensure Current.organization is set for each request
  def set_current_organization
    # This is needed because Current.organization gets reset between requests
    Current.organization = organization
    # Allow controller to access Current.organization
    allow(Current).to receive(:organization).and_return(organization)
  end
  
  describe 'DELETE #destroy' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: image.id, locale: locale }
        debug_request
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with HTML format' do
        context 'when image belongs to current organization' do
          it 'destroys the image and redirects with success notice' do
            set_current_organization
            delete :destroy, params: { id: image.id, locale: locale }
            debug_request
            
            expect(response).to redirect_to(edit_restaurant_path(id: restaurant.id, locale: locale))
            expect(flash[:notice]).to eq('Image was successfully deleted.')
            expect(Image.exists?(image.id)).to be false
          end

          it 'redirects with error notice when destroy fails' do
            set_current_organization
            allow_any_instance_of(Image).to receive(:destroy).and_return(false)
            delete :destroy, params: { id: image.id, locale: locale }
            debug_request
            
            expect(response).to redirect_to(edit_restaurant_path(id: restaurant.id, locale: locale))
            expect(flash[:alert]).to eq('Failed to delete image.')
            expect(Image.exists?(image.id)).to be true
          end
        end

        context 'when image belongs to different organization' do
          before do
            sign_in other_user
            Current.organization = other_organization
          end

          it 'redirects to root with error' do
            delete :destroy, params: { id: image.id, locale: locale }
            debug_request
            
            expect(response).to redirect_to(root_path)
            expect(flash[:alert]).to eq('You do not have permission to delete this image.')
            expect(Image.exists?(image.id)).to be true
          end
        end
      end

      context 'with JSON format' do
        context 'when image belongs to current organization' do
          it 'destroys the image and returns success JSON' do
            set_current_organization
            delete :destroy, params: { id: image.id, locale: locale }, format: :json
            debug_request
            
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)).to eq({ 'success' => true })
            expect(Image.exists?(image.id)).to be false
          end

          it 'returns error JSON when destroy fails' do
            set_current_organization
            allow_any_instance_of(Image).to receive(:destroy).and_return(false)
            delete :destroy, params: { id: image.id, locale: locale }, format: :json
            debug_request
            
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['success']).to be false
            expect(Image.exists?(image.id)).to be true
          end
        end

        context 'when image belongs to different organization' do
          before do
            sign_in other_user
            Current.organization = other_organization
          end

          it 'returns forbidden JSON' do
            delete :destroy, params: { id: image.id, locale: locale }, format: :json
            debug_request
            
            expect(response).to have_http_status(:forbidden)
            expect(JSON.parse(response.body)).to eq({
              'success' => false,
              'errors' => ['Permission denied']
            })
            expect(Image.exists?(image.id)).to be true
          end
        end
      end

      context 'with different imageable types' do
        let(:visit_image) { create(:image, imageable: visit) }

        it 'redirects to correct path for Visit' do
          set_current_organization
          delete :destroy, params: { id: visit_image.id, locale: locale }
          debug_request
          expect(response).to redirect_to(edit_visit_path(id: visit.id, locale: locale))
        end

        it 'redirects to root for unknown imageable type' do
          set_current_organization
          # Using a model that doesn't support images as an example of unsupported imageable
          class DummyModel < ApplicationRecord
            self.table_name = 'users' # Use an existing table for the test
          end
          unknown_imageable = DummyModel.create!
          unknown_image = create(:image, imageable: unknown_imageable)
          
          delete :destroy, params: { id: unknown_image.id, locale: locale }
          debug_request
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe '#edit_polymorphic_path' do
    before { sign_in user }

    context 'with unsupported imageable type' do
      it 'returns root_path' do
        set_current_organization
        class DummyModel < ApplicationRecord
          self.table_name = 'users' # Use an existing table for the test
        end
        unsupported_imageable = DummyModel.create!
        
        path = controller.send(:edit_polymorphic_path, unsupported_imageable)
        expect(path).to eq(root_path)
      end
    end

    context 'with supported imageable types' do
      it 'returns correct path for Restaurant' do
        set_current_organization
        path = controller.send(:edit_polymorphic_path, restaurant)
        expect(path).to eq(edit_restaurant_path(id: restaurant.id, locale: locale))
      end

      it 'returns correct path for Visit' do
        set_current_organization
        path = controller.send(:edit_polymorphic_path, visit)
        expect(path).to eq(edit_visit_path(id: visit.id, locale: locale))
      end
    end
  end

  describe 'POST #bulk_destroy' do
    let!(:image1) { create(:image, imageable: restaurant) }
    let!(:image2) { create(:image, imageable: restaurant) }
    let!(:other_org_image) { create(:image, imageable: create(:restaurant, organization: other_organization)) }

    before { sign_in user }

    it 'deletes multiple images from current organization' do
      set_current_organization
      expect {
        post :bulk_destroy, params: { image_ids: [image1.id, image2.id], locale: locale }, format: :json
        debug_request
      }.to change(Image, :count).by(-2)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include({
        'success' => true,
        'deleted_count' => 2
      })
    end

    it 'returns error when trying to delete images from another organization' do
      set_current_organization
      expect {
        post :bulk_destroy, params: { image_ids: [image1.id, other_org_image.id], locale: locale }, format: :json
        debug_request
      }.not_to change(Image, :count)

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to include({
        'error' => 'Unauthorized'
      })
    end

    it 'returns error when no images are selected' do
      set_current_organization
      post :bulk_destroy, params: { image_ids: [], locale: locale }, format: :json
      debug_request

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include({
        'error' => 'No images selected'
      })
    end
  end
end
