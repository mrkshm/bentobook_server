require "rails_helper"

RSpec.describe ShareeAvatarsComponent, type: :component do
  let(:owner) { create(:user) }
  let(:list) { create(:list, owner: owner) }
  let(:recipient) { create(:user) }

  context "when there are no shares" do
    it "does not render" do
      result = render_inline(described_class.new(list: list))
      expect(result.css(".flex")).not_to be_present
    end
  end

  context "with shares in different states" do
    before do
      allow_any_instance_of(Profile).to receive(:display_name).and_return("test_user")
    end

    it "renders pending share with correct tooltip" do
      create(:share, creator: owner, recipient: recipient, shareable: list, status: :pending)
      result = render_inline(described_class.new(list: list))
      
      expect(result.css(".opacity-50")).to be_present
      expect(result.css(".tooltip")).to be_present
      expect(result.css("[data-tip]").first['data-tip']).to eq(
        I18n.t("sharee_avatars_component.pending_tooltip", user: "test_user")
      )
    end

    it "renders accepted share with correct tooltip" do
      create(:share, creator: owner, recipient: recipient, shareable: list, status: :accepted)
      result = render_inline(described_class.new(list: list))
      
      expect(result.css(".opacity-50")).not_to be_present
      expect(result.css(".tooltip")).to be_present
      expect(result.css("[data-tip]").first['data-tip']).to eq(
        I18n.t("sharee_avatars_component.accepted_tooltip", user: "test_user")
      )
    end
  end

  context "with multiple shares" do
    it "renders all shares in correct order" do
      recipients = create_list(:user, 3)
      
      allow_any_instance_of(Profile).to receive(:display_name) do |profile|
        "user#{profile.user.id}"
      end
      
      shares = recipients.map do |user|
        create(:share, creator: owner, recipient: user, shareable: list, status: :accepted)
      end

      result = render_inline(described_class.new(list: list))
      
      expect(result.css(".flex")).to be_present
      expect(result.css(".avatar").count).to eq(3)
      expect(result.css(".tooltip").count).to eq(3)
      
      recipients.each_with_index do |user, index|
        name = "user#{user.id}"
        tooltip = I18n.t("sharee_avatars_component.accepted_tooltip", user: name)
        expect(result.css("[data-tip]")[index]['data-tip']).to eq(tooltip)
      end
    end
  end
end
