require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:restaurant) { create(:restaurant, organization: organization) }
  let!(:visit) { create(:visit, restaurant: restaurant, organization: organization) }
  let(:locale) { 'en' }

  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    sign_in user
    # Set Current.organization for the test
    Current.organization = organization
    
    puts "\n=== Test Setup ==="
    puts "Organization ID: #{organization.id}"
    puts "User ID: #{user.id}"
    puts "Restaurant ID: #{restaurant.id}"
    puts "Visit ID: #{visit.id}"
    puts "User's organizations: #{user.organizations.pluck(:id)}"
    puts "Current.organization: #{Current.organization&.id}"
    puts "Restaurant organization: #{restaurant.organization_id}"
    puts "Visit organization: #{visit.organization_id}"
    puts "==================="
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

  describe "GET #index" do
    it "returns a success response" do
      set_current_organization
      get :index, params: { locale: locale }
      debug_request
      expect(response).to be_successful
    end

    it "assigns @visits with associated data" do
      set_current_organization
      visit_with_image = create(:visit, :with_image, organization: organization)
      get :index, params: { locale: locale }
      debug_request
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
      set_current_organization
      get :show, params: { id: visit.to_param, locale: locale }
      debug_request
      expect(response).to be_successful
    end

    it "assigns the requested visit as @visit" do
      set_current_organization
      get :show, params: { id: visit.to_param, locale: locale }
      debug_request
      expect(assigns(:visit)).to eq(visit)
    end

    context "when visit is not found" do
      it "sets a flash alert" do
        set_current_organization
        get :show, params: { id: 'nonexistent', locale: locale }
        debug_request
        expect(flash[:alert]).to eq(I18n.t('errors.visits.not_found'))
      end

      it "redirects to visits path" do
        set_current_organization
        get :show, params: { id: 'nonexistent', locale: locale }
        debug_request
        expect(response).to redirect_to(visits_path)
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      set_current_organization
      get :new, params: { locale: locale }
      debug_request
      expect(response).to be_successful
    end

    it "assigns a new Visit to @visit" do
      set_current_organization
      get :new, params: { locale: locale }
      debug_request
      expect(assigns(:visit)).to be_a_new(Visit)
    end

    context "with restaurant_id parameter" do
      it "assigns the restaurant_id to the new visit" do
        set_current_organization
        get :new, params: { restaurant_id: restaurant.id, locale: locale }
        debug_request
        expect(assigns(:visit).restaurant_id).to eq(restaurant.id)
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { attributes_for(:visit, restaurant_id: restaurant.id) }

      it "creates a new Visit" do
        set_current_organization
        expect {
          post :create, params: { visit: valid_attributes, locale: locale }
          debug_request
        }.to change(Visit, :count).by(1)
      end

      it "redirects to the visits index" do
        set_current_organization
        post :create, params: { visit: valid_attributes, locale: locale }
        debug_request
        expect(response).to redirect_to(visits_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { attributes_for(:visit, restaurant_id: nil) }

      it "returns an unprocessable entity status" do
        set_current_organization
        post :create, params: { visit: invalid_attributes, locale: locale }
        debug_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new Visit" do
        set_current_organization
        expect {
          post :create, params: { visit: invalid_attributes, locale: locale }
          debug_request
        }.to_not change(Visit, :count)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(Visit).to receive(:save).and_return(false)
      end

      it "sets a flash alert" do
        set_current_organization
        post :create, params: { visit: attributes_for(:visit, restaurant_id: restaurant.id), locale: locale }
        debug_request
        expect(flash[:alert]).to eq(I18n.t('errors.visits.save_failed'))
      end

      it "renders new with unprocessable entity status" do
        set_current_organization
        post :create, params: { visit: attributes_for(:visit, restaurant_id: restaurant.id), locale: locale }
        debug_request
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when restaurant is not provided" do
      it "sets a flash alert and adds an error to @visit" do
        set_current_organization
        post :create, params: { visit: attributes_for(:visit, restaurant_id: nil), locale: locale }
        debug_request
        expect(flash.now[:alert]).to eq(I18n.t('errors.visits.restaurant_required'))
        expect(assigns(:visit).errors[:restaurant_id]).to include(I18n.t('errors.messages.blank'))
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      set_current_organization
      get :edit, params: { id: visit.to_param, locale: locale }
      debug_request
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { title: "Updated Title" } }

      it "updates the requested visit" do
        set_current_organization
        put :update, params: { id: visit.to_param, visit: new_attributes, locale: locale }
        debug_request
        visit.reload
        expect(visit.title).to eq("Updated Title")
      end

      it "redirects to the visits index" do
        set_current_organization
        put :update, params: { id: visit.to_param, visit: new_attributes, locale: locale }
        debug_request
        expect(response).to redirect_to(visits_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { restaurant_id: nil } }

      it "returns an unprocessable entity status" do
        set_current_organization
        put :update, params: { id: visit.to_param, visit: invalid_attributes, locale: locale }
        debug_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested visit" do
      set_current_organization
      visit_to_delete = create(:visit, organization: organization, restaurant: restaurant)
      expect {
        delete :destroy, params: { id: visit_to_delete.to_param, locale: locale }
        debug_request
      }.to change(Visit, :count).by(-1)
    end

    it "redirects to the visits list" do
      set_current_organization
      delete :destroy, params: { id: visit.to_param, locale: locale }
      debug_request
      expect(response).to redirect_to(visits_path)
    end
  end

  describe "visit_params" do
    it "converts price_paid to Money object" do
      set_current_organization
      post :create, params: { visit: attributes_for(:visit, price_paid: "10.50", price_paid_currency: "EUR", restaurant_id: restaurant.id), locale: locale }
      debug_request
      expect(assigns(:visit).price_paid).to be_a(Money)
      expect(assigns(:visit).price_paid.currency.iso_code).to eq("EUR")
      expect(assigns(:visit).price_paid.to_f).to eq(10.50)
    end
  end

  describe "ensure_valid_restaurant" do
    it "validates that the restaurant belongs to the current organization" do
      set_current_organization
      other_organization = create(:organization)
      other_restaurant = create(:restaurant, organization: other_organization)
      
      post :create, params: { visit: attributes_for(:visit, restaurant_id: other_restaurant.id), locale: locale }
      debug_request
      
      expect(flash[:alert]).to eq(I18n.t('errors.visits.invalid_restaurant'))
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "#save_visit" do
    context "when processing images" do
      let(:visit) { create(:visit, organization: organization, restaurant: restaurant) }
      let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
      let(:image_processor) { instance_double(ImageProcessorService) }
      let(:processor_result) { ImageProcessorService::Result.new(success: true) }
      
      before do
        set_current_organization
        controller.instance_variable_set(:@visit, visit)
        allow(ImageProcessorService).to receive(:new).and_return(image_processor)
      end

      it "redirects to visits path when no images are provided" do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { title: "Test Visit" },
            locale: locale
          )
        )
        
        expect(controller).to receive(:redirect_to).with(
          visits_path, 
          notice: I18n.t("notices.visits.created")
        )
        
        controller.send(:save_visit, :new)
      end

      it "handles successful image processing" do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] },
            locale: locale
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
            visit: { images: [image] },
            locale: locale
          )
        )
        
        failed_result = ImageProcessorService::Result.new(success: false, error: "Error")
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        controller.send(:save_visit, :new)
        expect(flash[:alert]).to eq("Error")
      end

      it "destroys new visits when image processing fails" do
        new_visit = create(:visit, organization: organization, restaurant: restaurant)
        controller.instance_variable_set(:@visit, new_visit)
        
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] },
            locale: locale
          )
        )
        
        failed_result = ImageProcessorService::Result.new(success: false, error: "Error")
        expect(image_processor).to receive(:process).and_return(failed_result)
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        expect {
          controller.send(:save_visit, :new)
        }.to change(Visit, :count).by(-1)
      end

      it "preserves existing visits when image processing fails during update" do
        existing_visit = create(:visit, organization: organization, restaurant: restaurant)
        controller.instance_variable_set(:@visit, existing_visit)
        
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(
            visit: { images: [image] },
            locale: locale
          )
        )
        
        failed_result = ImageProcessorService::Result.new(success: false, error: "Error")
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
      set_current_organization
      allow(ImageProcessorService).to receive(:new).and_return(image_processor)
    end

    context "when creating a visit" do
      it "processes images successfully" do
        expect(image_processor).to receive(:process).and_return(processor_result)
        
        post :create, params: { visit: valid_attributes_with_image, locale: locale }
        debug_request
        
        expect(response).to redirect_to(visits_path)
        expect(flash[:notice]).to eq(I18n.t("notices.visits.created"))
      end

      it "handles failed image processing" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        post :create, params: { visit: valid_attributes_with_image, locale: locale }
        debug_request
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "destroys the visit when image processing fails during creation" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect {
          post :create, params: { visit: valid_attributes_with_image, locale: locale }
          debug_request
        }.not_to change(Visit, :count)
      end
    end

    context "when updating a visit" do
      let!(:existing_visit) { create(:visit, organization: organization, restaurant: restaurant) }

      it "processes images successfully" do
        expect(image_processor).to receive(:process).and_return(processor_result)
        
        put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image, locale: locale }
        debug_request
        
        expect(response).to redirect_to(visits_path)
        expect(flash[:notice]).to eq(I18n.t("notices.visits.updated"))
      end

      it "handles failed image processing" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image, locale: locale }
        debug_request
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "does not destroy the visit when image processing fails during update" do
        expect(image_processor).to receive(:process).and_return(failed_result)
        
        expect {
          put :update, params: { id: existing_visit.to_param, visit: valid_attributes_with_image, locale: locale }
          debug_request
        }.not_to change(Visit, :count)
      end
    end
  end

  context "when accessing a visit from another organization" do
    let(:other_organization) { create(:organization) }
    let(:other_restaurant) { create(:restaurant, organization: other_organization) }
    let(:other_visit) { create(:visit, organization: other_organization, restaurant: other_restaurant) }

    it "redirects to visits path with not found message" do
      set_current_organization
      get :show, params: { id: other_visit.id, locale: locale }
      debug_request
      expect(flash[:alert]).to eq(I18n.t('errors.visits.not_found'))
      expect(response).to redirect_to(visits_path)
    end
  end
end
