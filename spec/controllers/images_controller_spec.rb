require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:visit) { create(:visit, user: user) }
  let(:image) { create(:image, imageable: restaurant) }
  
  describe 'DELETE #destroy' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: image.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with HTML format' do
        context 'when user owns the imageable' do
          it 'destroys the image and redirects with success notice' do
            delete :destroy, params: { id: image.id }
            
            expect(response).to redirect_to(edit_restaurant_path(restaurant))
            expect(flash[:notice]).to eq('Image was successfully deleted.')
            expect(Image.exists?(image.id)).to be false
          end

          it 'redirects with error notice when destroy fails' do
            allow_any_instance_of(Image).to receive(:destroy).and_return(false)
            delete :destroy, params: { id: image.id }
            
            expect(response).to redirect_to(edit_restaurant_path(restaurant))
            expect(flash[:alert]).to eq('Failed to delete image.')
            expect(Image.exists?(image.id)).to be true
          end
        end

        context 'when user does not own the imageable' do
          before { sign_in other_user }

          it 'redirects to root with error' do
            delete :destroy, params: { id: image.id }
            
            expect(response).to redirect_to(root_path)
            expect(flash[:alert]).to eq('You do not have permission to delete this image.')
            expect(Image.exists?(image.id)).to be true
          end
        end
      end

      context 'with JSON format' do
        context 'when user owns the imageable' do
          it 'destroys the image and returns success JSON' do
            delete :destroy, params: { id: image.id }, format: :json
            
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)).to eq({ 'success' => true })
            expect(Image.exists?(image.id)).to be false
          end

          it 'returns error JSON when destroy fails' do
            allow_any_instance_of(Image).to receive(:destroy).and_return(false)
            delete :destroy, params: { id: image.id }, format: :json
            
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['success']).to be false
            expect(Image.exists?(image.id)).to be true
          end
        end

        context 'when user does not own the imageable' do
          before { sign_in other_user }

          it 'returns forbidden JSON' do
            delete :destroy, params: { id: image.id }, format: :json
            
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
          delete :destroy, params: { id: visit_image.id }
          expect(response).to redirect_to(edit_visit_path(visit))
        end

        it 'redirects to root for unknown imageable type' do
          unknown_imageable = create(:user) # Using User as an example of unsupported imageable
          unknown_image = create(:image, imageable: unknown_imageable)
          
          delete :destroy, params: { id: unknown_image.id }
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe '#edit_polymorphic_path' do
    context 'with unsupported imageable type' do
      let(:unsupported_imageable) { create(:user) } # Using User as an unsupported type
      
      it 'returns root_path' do
        # Set up request environment
        @request.host = 'test.host'
        
        path = controller.send(:edit_polymorphic_path, unsupported_imageable)
        expect(path).to eq(root_path)
      end
    end

    context 'with supported imageable types' do
      let(:restaurant) { create(:restaurant, user: user) }
      let(:visit) { create(:visit, user: user) }
      
      before do
        @request.host = 'test.host'
      end
      
      it 'returns correct path for Restaurant' do
        path = controller.send(:edit_polymorphic_path, restaurant)
        expect(path).to eq(edit_restaurant_path(restaurant))
      end

      it 'returns correct path for Visit' do
        path = controller.send(:edit_polymorphic_path, visit)
        expect(path).to eq(edit_visit_path(visit))
      end
    end
  end
end
