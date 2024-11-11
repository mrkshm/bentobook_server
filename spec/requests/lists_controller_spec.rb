require 'rails_helper'

RSpec.describe ListsController, type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  
  before { sign_in user }

  describe 'GET /lists/:id/export' do
    context 'with markdown format' do
      it 'returns markdown file' do
        get "/lists/#{list.id}/export.text", params: { locale: I18n.locale }
        
        expect(response.headers['Content-Type']).to eq('text/markdown')
        expect(response.headers['Content-Disposition']).to include('.md')
        puts "Actual Content-Type: #{response.headers['Content-Type']}"
        puts "Response body: #{response.body[0..100]}" # First 100 chars
      end
    end
  end

  describe 'POST /lists/:id/export' do
    context 'with email sharing' do
      let(:valid_params) do
        { 
          email: 'test@example.com',
          include_stats: '1',
          format: :turbo_stream
        }
      end

      it 'sends email and shows success message' do
        puts "Testing email export..."
        
        expect {
          post "/lists/#{list.id}/export", 
               params: valid_params
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('success')
      end
    end
  end
end
