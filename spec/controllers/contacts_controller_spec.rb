require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:contact) }
  let(:invalid_attributes) { attributes_for(:contact, name: nil) }

  before { sign_in user }

  describe "GET #index" do
    let!(:contact1) { create(:contact, user: user, name: "Zach", email: "zach@test.net", created_at: 2.days.ago) }
    let!(:contact2) { create(:contact, user: user, name: "Amy", email: "amy@test.net", created_at: 1.day.ago) }
    let!(:contact3) { create(:contact, user: user, name: "Bob", email: "bob@test.net", created_at: Time.current) }
    
    before do
      # Create some visits for contact1
      create_list(:visit, 3, contacts: [contact1])
      # Create one visit for contact2
      create(:visit, contacts: [contact2])
      # contact3 has no visits
    end

    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    context "with ordering" do
      it "orders by name ascending" do
        get :index, params: { order_by: 'name', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([contact2, contact3, contact1]) # Amy, Bob, Zach
      end

      it "orders by name descending" do
        get :index, params: { order_by: 'name', order_direction: 'desc' }
        expect(assigns(:contacts).to_a).to eq([contact1, contact3, contact2]) # Zach, Bob, Amy
      end

      it "orders by email ascending" do
        get :index, params: { order_by: 'email', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([contact2, contact3, contact1]) # amy@, bob@, zach@
      end

      it "orders by email descending" do
        get :index, params: { order_by: 'email', order_direction: 'desc' }
        expect(assigns(:contacts).to_a).to eq([contact1, contact3, contact2]) # zach@, bob@, amy@
      end

      it "orders by visit count descending (default)" do
        get :index, params: { order_by: 'visits' }
        expect(assigns(:contacts).to_a).to eq([contact1, contact2, contact3]) # 3 visits, 1 visit, 0 visits
      end

      it "orders by visit count ascending" do
        get :index, params: { order_by: 'visits', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([contact3, contact2, contact1]) # 0 visits, 1 visit, 3 visits
      end

      it "orders by created_at descending by default when no order specified" do
        get :index
        expect(assigns(:contacts).to_a).to eq([contact3, contact2, contact1]) # newest to oldest
      end
    end

    context "with search parameter" do
      it "filters contacts by exact name match" do
        get :index, params: { search: "Amy" }
        expect(assigns(:contacts).to_a).to eq([contact2])
      end

      it "filters contacts by case-insensitive partial match" do
        get :index, params: { search: "am" }
        
        results = assigns(:contacts).to_a
        expect(results.length).to eq(1)
        expect(results.first).to eq(contact2)
        expect(results).not_to include(contact1, contact3)
      end

      it "filters contacts by email" do
        get :index, params: { search: "amy@test" }
        expect(assigns(:contacts).to_a).to eq([contact2])
      end

      it "returns all contacts when search is blank" do
        get :index, params: { search: "" }
        expect(assigns(:contacts).to_a).to eq([contact3, contact2, contact1])
      end

      it "returns all contacts when search is nil" do
        get :index
        expect(assigns(:contacts).to_a).to eq([contact3, contact2, contact1])
      end
    end
  end

  describe "GET #show" do
    context "when contact exists" do
      let(:contact) { create(:contact, user: user) }
      let!(:restaurant) { create(:restaurant, user: user) }
      let!(:visit) { create(:visit, restaurant: restaurant, contacts: [contact]) }
      let!(:image) { create(:image, imageable: visit) }
      let!(:other_contact) { create(:contact, user: user) }
      
      before do
        visit.contacts << other_contact
      end

      it "successfully loads the contact with all associations" do
        get :show, params: { id: contact.id }
        
        expect(response).to be_successful
        loaded_contact = assigns(:contact)
        expect(loaded_contact).to eq(contact)
        
        # Verify associations are loaded
        expect(loaded_contact.association(:visits)).to be_loaded
        visit = loaded_contact.visits.first
        expect(visit.association(:restaurant)).to be_loaded
        expect(visit.association(:images)).to be_loaded
        expect(visit.association(:contacts)).to be_loaded
      end
    end

    context "when contact does not exist" do
      it "logs error and redirects to contacts path" do
        # Skip the before_action to test the show action's rescue block directly
        allow(controller).to receive(:set_contact)
        
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact 999 for user #{user.id}")

        # Force the find to raise RecordNotFound
        expect_any_instance_of(ActiveRecord::Relation)
          .to receive(:find)
          .and_raise(ActiveRecord::RecordNotFound)

        get :show, params: { id: 999 }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end

    context "when contact belongs to another user" do
      let(:other_user) { create(:user) }
      let(:other_contact) { create(:contact, user: other_user) }

      it "logs error and redirects to contacts path" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact #{other_contact.id} for user #{user.id}")

        get :show, params: { id: other_contact.id }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      contact = create(:contact, user: user)
      get :edit, params: { id: contact.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Contact" do
        expect {
          post :create, params: { contact: valid_attributes }
        }.to change(Contact, :count).by(1)
      end

      it "redirects to the created contact" do
        post :create, params: { contact: valid_attributes }
        created_contact = Contact.last
        expect(response).to redirect_to(
          contact_path(id: created_contact.id, locale: I18n.locale)
        )
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { contact: invalid_attributes, locale: :en }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with avatar" do
      let(:avatar) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
      
      it "processes the avatar image" do
        expect(ImageHandlingService).to receive(:process_images)
          .with(kind_of(Contact), kind_of(ActionController::Parameters), compress: true)
          .and_return(true)

        post :create, params: { 
          contact: valid_attributes.merge(avatar: avatar),
          locale: I18n.locale
        }
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

      it "updates the requested contact" do
        contact = create(:contact, user: user)
        put :update, params: { id: contact.to_param, contact: new_attributes }
        contact.reload
        expect(contact.name).to eq("New Name")
      end

      it "redirects to the contacts list" do
        contact = create(:contact, user: user)
        put :update, params: { id: contact.to_param, contact: valid_attributes }
        expect(response).to redirect_to(contacts_path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        contact = create(:contact, user: user)
        put :update, params: { id: contact.to_param, contact: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with avatar" do
      let(:contact) { create(:contact, user: user) }
      let(:avatar) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
      
      it "processes the avatar image" do
        expect(ImageHandlingService).to receive(:process_images)
          .with(contact, kind_of(ActionController::Parameters), compress: true)
          .and_return(true)

        put :update, params: { 
          id: contact.to_param,
          contact: valid_attributes.merge(avatar: avatar),
          locale: I18n.locale
        }
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested contact" do
      contact = create(:contact, user: user)
      expect {
        delete :destroy, params: { id: contact.to_param }
      }.to change(Contact, :count).by(-1)
    end

    it "redirects to the contacts list" do
      contact = create(:contact, user: user)
      delete :destroy, params: { id: contact.to_param }
      expect(response).to redirect_to(contacts_path)
    end

    context "when destroy fails" do
      it "logs the error and redirects to contacts path with an alert" do
        contact = create(:contact, user: user)
        allow_any_instance_of(Contact).to receive(:destroy).and_return(false)
        allow_any_instance_of(Contact).to receive_message_chain(:errors, :full_messages).and_return(['Some error'])

        expect(Rails.logger).to receive(:error).with("Failed to delete contact: [\"Some error\"]")

        delete :destroy, params: { id: contact.to_param }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Failed to delete contact.')
      end
    end
  end

  describe "set_contact" do
    context "when contact is not found" do
      it "logs the error and redirects to contacts path with an alert" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact 999 for user #{user.id}")

        get :show, params: { id: 999 }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end
  end

  describe "Error handling" do
    context "when contact is not found" do
      before do
        allow(Rails.logger).to receive(:error)
      end

      it "logs access attempt to invalid contact" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact 999 for user #{user.id}")

        get :show, params: { id: 999 }
      end

      %w[show edit update destroy].each do |action|
        it "redirects to contacts path with alert for #{action} action" do
          verb = case action
                 when 'show', 'edit' then :get
                 when 'update' then :put
                 when 'destroy' then :delete
                 end

          send(verb, action, params: { id: 999 })
          
          expect(response).to redirect_to(contacts_path)
          expect(flash[:alert]).to eq('Contact not found.')
        end
      end
    end

    context "when contact belongs to another user" do
      let(:other_user_contact) { create(:contact, user: create(:user)) }

      %w[show edit update destroy].each do |action|
        it "redirects to contacts path with alert for #{action} action" do
          verb = case action
                 when 'show', 'edit' then :get
                 when 'update' then :put
                 when 'destroy' then :delete
                 end

          send(verb, action, params: { id: other_user_contact.id })
          
          expect(response).to redirect_to(contacts_path)
          expect(flash[:alert]).to eq('Contact not found.')
        end
      end
    end
  end

  describe "Parameter filtering" do
    let(:contact) { create(:contact, user: user) }
    
    before(:each) do
      Contact.destroy_all # Clean up any existing contacts
    end

    it "permits all allowed parameters except avatar" do
      # Create a unique contact first
      contact = create(:contact, user: user)
      
      allowed_params = {
        name: "New Name #{SecureRandom.hex(4)}",
        email: "new#{SecureRandom.hex(4)}@example.com",
        city: "New City",
        country: "New Country",
        phone: "1234567890",
        notes: "New Notes"
      }

      # Test create action
      expect {
        post :create, params: { contact: allowed_params }
      }.to change(Contact, :count).by(1)

      created_contact = Contact.last
      allowed_params.each do |key, value|
        expect(created_contact.send(key)).to eq(value)
      end

      # Test update action with unique name
      update_params = allowed_params.merge(name: "Updated Name #{SecureRandom.hex(4)}")
      put :update, params: { id: contact.id, contact: update_params }
      
      expect(response).to redirect_to(contacts_path)
      
      contact.reload
      update_params.each do |key, value|
        expect(contact.send(key)).to eq(value)
      end
    end

    it "filters out non-permitted parameters" do
      # Create a unique contact first
      contact = create(:contact, user: user)
      
      non_permitted_params = {
        name: "New Name #{SecureRandom.hex(4)}",
        admin: true,
        role: "admin",
        user_id: create(:user).id
      }

      # Test create action
      expect {
        post :create, params: { contact: non_permitted_params }
      }.to change(Contact, :count).by(1)
      
      created_contact = Contact.last
      expect(created_contact.name).to eq(non_permitted_params[:name])
      expect(created_contact.user_id).to eq(user.id)

      # Test update action with unique name
      update_params = non_permitted_params.merge(name: "Updated Name #{SecureRandom.hex(4)}")
      put :update, params: { id: contact.id, contact: update_params }
      
      expect(response).to redirect_to(contacts_path)
      
      contact.reload
      expect(contact.name).to eq(update_params[:name])
      expect(contact.user_id).to eq(user.id)
    end

    it "handles avatar separately through ImageHandlingService" do
      avatar = fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg')
      
      expect(ImageHandlingService).to receive(:process_images)
        .with(kind_of(Contact), kind_of(ActionController::Parameters), compress: true)
        .and_return(true)

      put :update, params: { 
        id: contact.id, 
        contact: { name: "New Name", avatar: avatar }
      }
    end

    it "handles missing parameters gracefully" do
      expect {
        post :create, params: {}
      }.to raise_error(ActionController::ParameterMissing)

      expect {
        put :update, params: { id: contact.id }
      }.to raise_error(ActionController::ParameterMissing)
    end
  end
end

# Add this to spec/support/matchers/trigger_error_log_matcher.rb
RSpec::Matchers.define :trigger_error_log do |expected_message|
  supports_block_expectations

  match do |block|
    expect(Rails.logger).to receive(:error).with(expected_message)
    begin
      block.call
    rescue ActiveRecord::RecordNotFound
      true
    end
  end

  failure_message do |block|
    "expected that block would trigger error log with message #{expected_message.inspect}"
  end
end
