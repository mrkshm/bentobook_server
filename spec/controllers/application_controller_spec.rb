require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
      super
    end
  end

  describe "#after_sign_in_path_for" do
    let(:user) { create(:user) }

    context "when there is a stored location" do
      it "returns the stored location" do
        stored_location = '/some/stored/path'
        allow(controller).to receive(:stored_location_for).with(user).and_return(stored_location)
        expect(controller.after_sign_in_path_for(user)).to eq(stored_location)
      end
    end

    context "when there is no stored location" do
      it "returns the root path" do
        allow(controller).to receive(:stored_location_for).with(user).and_return(nil)
        expect(controller.after_sign_in_path_for(user)).to eq(root_path)
      end
    end
  end
end

