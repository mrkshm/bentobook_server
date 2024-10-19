require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hello, World!'
    end
  end

  describe "GET #index" do
    it "returns http success" do
      routes.draw { get "index" => "anonymous#index" }
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
