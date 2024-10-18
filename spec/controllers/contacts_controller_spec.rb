require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:contact) }
  let(:invalid_attributes) { attributes_for(:contact, name: nil) }

  before { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      create(:contact, user: user)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      contact = create(:contact, user: user)
      get :show, params: { id: contact.to_param }
      expect(response).to be_successful
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
        expect(response).to redirect_to(Contact.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { contact: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
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
        expect(Rails.logger).to receive(:error).with(/Attempted to access invalid contact \d+ for user #{user.id}/)

        get :show, params: { id: 999999 }

        expect(response).to redirect_to(contacts_path)
        expect(flash[:alert]).to eq('Contact not found.')
      end
    end
  end
end
