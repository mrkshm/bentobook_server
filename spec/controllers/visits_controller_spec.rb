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

    describe "POST #create with image processing" do
      let(:image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:valid_attributes) { attributes_for(:visit, restaurant_id: restaurant.id) }

      context "when image processing fails" do
        let(:valid_visit_attributes) { attributes_for(:visit, restaurant_id: restaurant.id) }
        
        before do
          allow(ImageHandlingService).to receive(:process_images).and_raise(StandardError.new("Processing failed"))
        end

        it "renders the appropriate template with unprocessable_entity status and logs the error" do
          expect(Rails.logger).to receive(:error).with("Image processing failed: Processing failed")
          post :create, params: { 
            visit: valid_visit_attributes,
            images: [fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg')]
          }
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
        end

        it "destroys the visit when image processing fails" do
          expect {
            post :create, params: { 
              visit: valid_visit_attributes,
              images: [fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg')]
            }
          }.not_to change(Visit, :count)
        end
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

  describe "save_visit" do
    let(:user) { create(:user) }
    let(:restaurant) { create(:restaurant, user: user) }

    before { sign_in user }

    context "when restaurant_id is nil" do
      it "renders the appropriate template with unprocessable_entity status" do
        visit = Visit.new
        setup_controller_for_save_visit(visit)
        
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        controller.send(:save_visit, :new)
        
        expect(flash.now[:alert]).to eq(I18n.t('errors.visits.restaurant_required'))
        expect(visit.errors[:restaurant_id]).to include("can't be blank")
      end
    end

    context "when visit saves successfully" do
      it "redirects to visits_path with a notice" do
        visit = build(:visit, user: user, restaurant: restaurant)
        setup_controller_for_save_visit(visit)
        
        allow(visit).to receive(:save).and_return(true)
        allow(controller).to receive(:process_images)
        expect(controller).to receive(:redirect_to).with(visits_path)
        
        controller.send(:save_visit, :new)
        
        expect(flash[:notice]).to eq(I18n.t("notices.visits.created"))
      end
    end

    context "when image processing fails" do
      it "renders the appropriate template with unprocessable_entity status and logs the error" do
        visit = create(:visit, user: user, restaurant: restaurant)
        setup_controller_for_save_visit(visit)
        
        allow(controller).to receive(:process_images).and_raise(StandardError.new("Processing failed"))
        expect(Rails.logger).to receive(:error).with("Image processing failed: Processing failed")
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        controller.send(:save_visit, :new)
        
        expect(flash[:alert]).to eq(I18n.t('errors.visits.image_processing_failed'))
      end

      it "destroys the visit when image processing fails" do
        visit = create(:visit, user: user, restaurant: restaurant)
        setup_controller_for_save_visit(visit)
        
        allow(controller).to receive(:process_images).and_raise(StandardError.new("Processing failed"))
        
        expect { controller.send(:save_visit, :new) }.to change(Visit, :count).by(-1)
      end
    end

    context "when visit fails to save" do
      it "renders the appropriate template with unprocessable_entity status" do
        visit = build(:visit, user: user, restaurant: restaurant)
        setup_controller_for_save_visit(visit)
        
        allow(visit).to receive(:save).and_return(false)
        expect(controller).to receive(:render).with(:new, status: :unprocessable_entity)
        
        controller.send(:save_visit, :new)
        
        expect(flash.now[:alert]).to eq(I18n.t('errors.visits.save_failed'))
      end
    end
  end

  describe "POST #create with images" do
    let(:valid_attributes) { attributes_for(:visit, restaurant_id: restaurant.id) }
    let(:image1) { fixture_file_upload('spec/fixtures/test_image1.jpg', 'image/jpeg') }
    let(:image2) { fixture_file_upload('spec/fixtures/test_image2.jpg', 'image/jpeg') }

    it "permits multiple images" do
      expect(ImageHandlingService).to receive(:process_images) do |visit, images|
        expect(visit).to be_a(Visit)
        expect(images.length).to eq(2)
        expect(images[0]).to be_a(ActionDispatch::Http::UploadedFile)
        expect(images[1]).to be_a(ActionDispatch::Http::UploadedFile)
        expect(images[0].original_filename).to eq('test_image1.jpg')
        expect(images[1].original_filename).to eq('test_image2.jpg')
      end
      
      post :create, params: { 
        visit: valid_attributes, 
        images: [image1, image2]
      }
      
      expect(response).to redirect_to(visits_path)
      expect(flash[:notice]).to eq(I18n.t("notices.visits.created"))
    end

    it "handles no images" do
      expect(ImageHandlingService).not_to receive(:process_images)
      
      post :create, params: { 
        visit: valid_attributes
      }
      
      expect(response).to redirect_to(visits_path)
      expect(flash[:notice]).to eq(I18n.t("notices.visits.created"))
    end
  end

  describe "image_params" do
    it "permits images parameter" do
      controller = VisitsController.new
      params = ActionController::Parameters.new(
        visit: { 
          title: "Test Visit",
          images: [fixture_file_upload('spec/fixtures/test_image1.jpg', 'image/jpeg')]
        }
      )
      allow(controller).to receive(:params).and_return(params)

      result = controller.send(:image_params)
      expect(result.to_h["images"].first).to be_kind_of(Rack::Test::UploadedFile).or be_kind_of(ActionDispatch::Http::UploadedFile)
    end

    it "does not permit other parameters" do
      controller = VisitsController.new
      params = ActionController::Parameters.new(
        visit: { 
          title: "Test Visit",
          images: [fixture_file_upload('spec/fixtures/test_image1.jpg', 'image/jpeg')],
          unpermitted_param: "This should not be permitted"
        }
      )
      allow(controller).to receive(:params).and_return(params)

      result = controller.send(:image_params)
      expect(result.to_h).not_to have_key("unpermitted_param")
    end
  end

  def setup_controller_for_save_visit(visit)
    controller.instance_variable_set(:@visit, visit)
    allow(controller).to receive(:render)
    allow(controller).to receive(:redirect_to)
    allow(controller).to receive(:process_images)
  end
end
