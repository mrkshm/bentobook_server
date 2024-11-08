require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:visit) { create(:visit, user: user, restaurant: restaurant) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @visits with associated data" do
      visit_with_image = create(:visit, :with_image, user: user)
      get :index
      expect(assigns(:pagy)).to be_a(Pagy)
      expect(assigns(:visits)).to include(visit_with_image)

      # Verify that associations are eager loaded
      queries = []
      ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, details|
        queries << details[:sql] unless details[:sql].include?("SCHEMA")
      end

      assigns(:visits).each do |v|
        v.restaurant
        v.contacts
        v.images.each { |i| i.file.blob }
      end

      expect(queries.count).to be <= 1
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: visit.to_param }
      expect(response).to be_successful
    end

    it "assigns the requested visit as @visit" do
      get :show, params: { id: visit.to_param }
      expect(assigns(:visit)).to eq(visit)
    end

    context "when visit is not found" do
      it "sets a flash alert" do
        get :show, params: { id: 'nonexistent' }
        expect(flash[:alert]).to eq(I18n.t('errors.visits.not_found'))
      end

      it "redirects to visits path" do
        get :show, params: { id: 'nonexistent' }
        expect(response).to redirect_to(visits_path)
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new Visit to @visit" do
      get :new
      expect(assigns(:visit)).to be_a_new(Visit)
    end

    context "with restaurant_id parameter" do
      it "assigns the restaurant_id to the new visit" do
        get :new, params: { restaurant_id: restaurant.id }
        expect(assigns(:visit).restaurant_id).to eq(restaurant.id)
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { attributes_for(:visit, restaurant_id: restaurant.id) }

      it "creates a new Visit" do
        expect {
          post :create, params: { visit: valid_attributes }
        }.to change(Visit, :count).by(1)
      end

      it "redirects to the visits index" do
        post :create, params: { visit: valid_attributes }
        expect(response).to redirect_to(visits_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { attributes_for(:visit, restaurant_id: nil) }

      it "returns an unprocessable entity status" do
        post :create, params: { visit: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new Visit" do
        expect {
          post :create, params: { visit: invalid_attributes }
        }.to_not change(Visit, :count)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(Visit).to receive(:save).and_return(false)
      end

      it "sets a flash alert" do
        post :create, params: { visit: attributes_for(:visit, restaurant_id: restaurant.id) }
        expect(flash[:alert]).to eq(I18n.t('errors.visits.save_failed'))
      end

      it "renders new with unprocessable entity status" do
        post :create, params: { visit: attributes_for(:visit, restaurant_id: restaurant.id) }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when restaurant is not provided" do
      it "sets a flash alert and adds an error to @visit" do
        post :create, params: { visit: attributes_for(:visit, restaurant_id: nil) }
        expect(flash[:alert]).to eq(I18n.t('errors.visits.restaurant_required'))
        expect(assigns(:visit).errors[:restaurant_id]).to include(I18n.t('errors.messages.blank'))
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when save fails due to validation errors" do
      let(:invalid_attributes) { attributes_for(:visit, restaurant_id: restaurant.id, date: nil) }

      it "sets a flash alert, renders new template, and returns unprocessable entity status" do
        post :create, params: { visit: invalid_attributes }
        
        expect(flash.now[:alert]).to eq(I18n.t('errors.visits.save_failed'))
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new Visit" do
        expect {
          post :create, params: { visit: invalid_attributes }
        }.not_to change(Visit, :count)
      end

      it "assigns @visit with the invalid visit object" do
        post :create, params: { visit: invalid_attributes }
        expect(assigns(:visit)).to be_a_new(Visit)
        expect(assigns(:visit)).to be_invalid
      end
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: visit.to_param }
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { title: "Updated Title" } }

      it "updates the requested visit" do
        put :update, params: { id: visit.to_param, visit: new_attributes }
        visit.reload
        expect(visit.title).to eq("Updated Title")
      end

      it "redirects to the visits index" do
        put :update, params: { id: visit.to_param, visit: new_attributes }
        expect(response).to redirect_to(visits_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { restaurant_id: nil } }

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: visit.to_param, visit: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested visit" do
      visit_to_delete = create(:visit, user: user)
      expect {
        delete :destroy, params: { id: visit_to_delete.to_param }
      }.to change(Visit, :count).by(-1)
    end

    it "redirects to the visits list" do
      delete :destroy, params: { id: visit.to_param }
      expect(response).to redirect_to(visits_path)
    end
  end

  describe "visit_params" do
    it "converts price_paid to Money object" do
      sign_in create(:user)
      post :create, params: { visit: attributes_for(:visit, price_paid: "10.50", price_paid_currency: "EUR") }
      expect(assigns(:visit).price_paid).to be_a(Money)
      expect(assigns(:visit).price_paid.currency.iso_code).to eq("EUR")
      expect(assigns(:visit).price_paid.cents).to eq(1050)
    end

    it "uses USD as default currency if not specified" do
      sign_in create(:user)
      post :create, params: { visit: attributes_for(:visit, price_paid: "10.50") }
      expect(assigns(:visit).price_paid.currency.iso_code).to eq("USD")
    end
  end

  describe "ensure_valid_restaurant" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:restaurant) { create(:restaurant, user: other_user) }

    before { sign_in user }

    it "adds an error and sets flash alert for invalid restaurant" do
      post :create, params: { visit: attributes_for(:visit, restaurant_id: restaurant.id) }
      expect(assigns(:visit).errors[:restaurant_id]).to include("is invalid")
      expect(flash[:alert]).to eq(I18n.t('errors.visits.invalid_restaurant'))
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "#save_visit" do
    context "when processing images" do
      let(:visit) { create(:visit, user: user, restaurant: restaurant) }
      let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
      let(:image_processor) { instance_double(ImageProcessorService) }
      let(:processor_result) { ImageProcessorService::Result.new(success: true) }
      let(:failed_result) { ImageProcessorService::Result.new(success: false, error: I18n.t('errors.visits.image_processing_failed')) }
      
      before do
        controller.instance_variable_set(:@visit, visit)
        controller.instance_variable_set(:@_response, ActionDispatch::Response.new)
        allow(ImageProcessorService).to receive(:new).and_return(image_processor)
      end

      it "skips image processing when no images are present" do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(visit: { title: "Test Visit" })
        )
        
        expect(ImageProcessorService).not_to receive(:new)
        
        expect(controller).to receive(:redirect_to).with(
          visits_path, 
          notice: I18n.t("notices.visits.created")
        )
        
        controller.send(:save_visit, :new)
      end

      it "handles successful image processing" do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] }
          )
        )
        expect(image_processor).to receive(:process).and_return(processor_result)
        
        expect(controller).to receive(:redirect_to).with(
          visits_path, 
          notice: I18n.t("notices.visits.created")
        )
        
        controller.send(:save_visit, :new)
      end

      it "handles failed image processing" do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] }
          )
        )
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        controller.send(:save_visit, :new)
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "destroys new visits when image processing fails" do
        new_visit = create(:visit, user: user, restaurant: restaurant)
        controller.instance_variable_set(:@visit, new_visit)
        
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] }
          )
        )
        expect(image_processor).to receive(:process).and_return(failed_result)
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        expect {
          controller.send(:save_visit, :new)
        }.to change(Visit, :count).by(-1)
      end

      it "preserves existing visits when image processing fails during update" do
        existing_visit = create(:visit, user: user, restaurant: restaurant)
        controller.instance_variable_set(:@visit, existing_visit)
        
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] }
          )
        )
        expect(image_processor).to receive(:process).and_return(failed_result)
        expect(controller).to receive(:render).with(:edit, status: :unprocessable_entity)
        
        expect {
          controller.send(:save_visit, :edit)
        }.not_to change(Visit, :count)
      end
    end
  end

  describe "image processing" do
    let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
    let(:valid_attributes_with_image) { attributes_for(:visit, restaurant_id: restaurant.id, images: [image]) }
    let(:image_processor) { instance_double(ImageProcessorService) }
    let(:processor_result) { ImageProcessorService::Result.new(success: true) }
    let(:failed_result) { ImageProcessorService::Result.new(success: false, error: I18n.t('errors.visits.image_processing_failed')) }

    before do
      allow(ImageProcessorService).to receive(:new).and_return(image_processor)
    end

    context "when creating a visit" do
      it "processes images successfully" do
        expect(image_processor).to receive(:process).and_return(processor_result)
        
        post :create, params: { visit: valid_attributes_with_image }
        
        expect(response).to redirect_to(visits_path)
        expect(flash[:notice]).to eq(I18n.t("notices.visits.created"))
      end

      it "handles failed image processing" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        post :create, params: { visit: valid_attributes_with_image }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "destroys the visit when image processing fails during creation" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect {
          post :create, params: { visit: valid_attributes_with_image }
        }.not_to change(Visit, :count)
      end
    end

    context "when updating a visit" do
      let!(:existing_visit) { create(:visit, user: user, restaurant: restaurant) }

      it "processes images successfully" do
        expect(image_processor).to receive(:process).and_return(processor_result)
        
        put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image }
        
        expect(response).to redirect_to(visits_path)
        expect(flash[:notice]).to eq(I18n.t("notices.visits.updated"))
      end

      it "handles failed image processing" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "does not destroy the visit when image processing fails during update" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect {
          put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image }
        }.not_to change(Visit, :count)
      end
    end
  end
end
