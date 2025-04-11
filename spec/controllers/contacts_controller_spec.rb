require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }
  let(:valid_attributes) { attributes_for(:contact).merge(organization: organization) }
  let(:invalid_attributes) { attributes_for(:contact, name: nil) }

  before { sign_in user }

  describe "GET #index" do
    let!(:contact1) { create(:contact, organization: organization, name: "Zach", email: "zach@test.net", created_at: 2.days.ago) }
    let!(:contact2) { create(:contact, organization: organization, name: "Amy", email: "amy@test.net", created_at: 1.day.ago) }
    let!(:contact3) { create(:contact, organization: organization, name: "Bob", email: "bob@test.net", created_at: Time.current) }

    before do
      # Create some visits for contact1
      create_list(:visit, 3, organization: organization, contacts: [ contact1 ])
      # Create one visit for contact2
      create(:visit, organization: organization, contacts: [ contact2 ])
      # contact3 has no visits
    end

    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    context "with ordering" do
      it "orders by name ascending" do
        get :index, params: { order_by: 'name', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([ contact2, contact3, contact1 ]) # Amy, Bob, Zach
      end

      it "orders by name descending" do
        get :index, params: { order_by: 'name', order_direction: 'desc' }
        expect(assigns(:contacts).to_a).to eq([ contact1, contact3, contact2 ]) # Zach, Bob, Amy
      end

      it "orders by email ascending" do
        get :index, params: { order_by: 'email', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([ contact2, contact3, contact1 ]) # amy@, bob@, zach@
      end

      it "orders by email descending" do
        get :index, params: { order_by: 'email', order_direction: 'desc' }
        expect(assigns(:contacts).to_a).to eq([ contact1, contact3, contact2 ]) # zach@, bob@, amy@
      end

      it "orders by visit count descending (default)" do
        get :index, params: { order_by: 'visits' }
        expect(assigns(:contacts).to_a).to eq([ contact1, contact2, contact3 ]) # 3 visits, 1 visit, 0 visits
      end

      it "orders by visit count ascending" do
        get :index, params: { order_by: 'visits', order_direction: 'asc' }
        expect(assigns(:contacts).to_a).to eq([ contact3, contact2, contact1 ]) # 0 visits, 1 visit, 3 visits
      end

      it "orders by created_at descending by default when no order specified" do
        get :index
        expect(assigns(:contacts).to_a).to eq([ contact3, contact2, contact1 ]) # newest to oldest
      end
    end

    context "with search parameter" do
      it "filters contacts by exact name match" do
        get :index, params: { search: "Amy" }
        expect(assigns(:contacts).to_a).to eq([ contact2 ])
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
        expect(assigns(:contacts).to_a).to eq([ contact2 ])
      end

      it "returns all contacts when search is blank" do
        get :index, params: { search: "" }
        expect(assigns(:contacts).to_a).to eq([ contact3, contact2, contact1 ])
      end

      it "returns all contacts when search is nil" do
        get :index
        expect(assigns(:contacts).to_a).to eq([ contact3, contact2, contact1 ])
      end
    end
  end

  describe "GET #show" do
    context "when contact exists" do
      let(:contact) { create(:contact, organization: organization) }
      let!(:restaurant) { create(:restaurant, organization: organization) }
      let!(:visit) { create(:visit, organization: organization, restaurant: restaurant, contacts: [ contact ]) }
      let!(:image) { create(:image, imageable: visit) }
      let!(:other_contact) { create(:contact, organization: organization) }

      before do
        visit.contacts << other_contact
      end

      it "successfully loads the contact with all associations" do
        get :show, params: { id: contact.to_param }
        expect(response).to be_successful

        loaded_contact = assigns(:contact)
        expect(loaded_contact).to eq(contact)
        expect(loaded_contact.association(:visits)).to be_loaded

        visit = loaded_contact.visits.first
        expect(visit.association(:restaurant)).to be_loaded
        expect(visit.association(:images)).to be_loaded
        expect(visit.association(:contacts)).to be_loaded
      end
    end

    context "when contact does not exist" do
      it "logs error and redirects to contacts path" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact 999 for organization #{organization.id}")

        get :show, params: { id: 999 }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end

    context "when contact belongs to another organization" do
      let(:other_org) { create(:organization) }
      let(:other_contact) { create(:contact, organization: other_org) }

      it "logs error and redirects to contacts path" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact #{other_contact.id} for organization #{organization.id}")

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
      contact = create(:contact, organization: organization)
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
        expect(response).to redirect_to(contact_path(Contact.last, locale: I18n.locale))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { contact: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with avatar" do
      let(:avatar) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

      it "processes the avatar image" do
        contact = nil
        expect(PreprocessAvatarService).to receive(:call) do |arg|
          contact = arg
          { success: true, variants: { medium: avatar, thumbnail: avatar } }
        end

        post :create, params: {
          contact: valid_attributes.merge(avatar: avatar)
        }

        expect(contact).to be_a(Contact)
        expect(contact.organization).to eq(organization)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

      it "updates the requested contact" do
        contact = create(:contact, organization: organization)
        put :update, params: { id: contact.to_param, contact: new_attributes }
        contact.reload
        expect(contact.name).to eq("New Name")
      end

      it "redirects to the contacts list" do
        contact = create(:contact, organization: organization)
        put :update, params: { id: contact.to_param, contact: valid_attributes }
        expect(response).to redirect_to(contacts_path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        contact = create(:contact, organization: organization)
        put :update, params: { id: contact.to_param, contact: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with avatar" do
      let(:contact) { create(:contact, organization: organization) }
      let(:avatar) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

      it "processes the avatar image" do
        expect(PreprocessAvatarService).to receive(:call)
          .with(contact)
          .and_return({ success: true, variants: { medium: avatar, thumbnail: avatar } })

        put :update, params: {
          id: contact.to_param,
          contact: valid_attributes.merge(avatar: avatar)
        }
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested contact" do
      contact = create(:contact, organization: organization)
      expect {
        delete :destroy, params: { id: contact.to_param }
      }.to change(Contact, :count).by(-1)
    end

    it "redirects to the contacts list" do
      contact = create(:contact, organization: organization)
      delete :destroy, params: { id: contact.to_param }
      expect(response).to redirect_to(contacts_path)
    end

    context "when destroy fails" do
      it "logs the error and redirects to contacts path with an alert" do
        contact = create(:contact, organization: organization)
        allow(contact).to receive(:destroy).and_return(false)

        # Set up Current.organization
        allow(Current).to receive(:organization).and_return(organization)
        allow(organization.contacts).to receive(:find).and_return(contact)

        expect(Rails.logger).to receive(:error)
          .with("Failed to delete contact #{contact.id} for organization #{organization.id}")

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
          .with("Attempted to access invalid contact 999 for organization #{organization.id}")

        get :show, params: { id: 999 }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end
  end

  describe "Error handling" do
    context "when contact is not found" do
      it "logs access attempt to invalid contact" do
        expect(Rails.logger).to receive(:error)
          .with("Attempted to access invalid contact 999 for organization #{organization.id}")

        get :show, params: { id: 999 }
      end
    end

    context "when contact belongs to another organization" do
      let(:other_org) { create(:organization) }
      let(:other_contact) { create(:contact, organization: other_org) }

      %w[show edit update destroy].each do |action|
        it "redirects to contacts path with alert for #{action} action" do
          verb = case action
          when 'show', 'edit' then :get
          when 'update' then :put
          when 'destroy' then :delete
          end

          send(verb, action, params: { id: other_contact.id })

          expect(response).to redirect_to(contacts_path)
          expect(flash[:alert]).to eq('Contact not found.')
        end
      end
    end
  end

  describe "Parameter filtering" do
    let(:contact) { create(:contact, organization: organization) }

    before(:each) do
      Contact.destroy_all # Clean up any existing contacts
    end

    it "permits all allowed parameters except avatar" do
      # Create a unique contact first
      contact = create(:contact, organization: organization)

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
      contact = create(:contact, organization: organization)

      non_permitted_params = {
        name: "New Name #{SecureRandom.hex(4)}",
        admin: true,
        role: "admin",
        organization_id: create(:organization).id
      }

      # Test create action
      expect {
        post :create, params: { contact: non_permitted_params }
      }.to change(Contact, :count).by(1)

      created_contact = Contact.last
      expect(created_contact.name).to eq(non_permitted_params[:name])
      expect(created_contact.organization_id).to eq(organization.id)

      # Test update action with unique name
      update_params = non_permitted_params.merge(name: "Updated Name #{SecureRandom.hex(4)}")
      put :update, params: { id: contact.id, contact: update_params }

      expect(response).to redirect_to(contacts_path)

      contact.reload
      expect(contact.name).to eq(update_params[:name])
      expect(contact.organization_id).to eq(organization.id)
    end

    it "handles avatar through PreprocessAvatarService" do
      avatar = fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg')

      expect(PreprocessAvatarService).to receive(:call)
        .with(contact)
        .and_return({ success: true, variants: { medium: avatar, thumbnail: avatar } })

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
