require "rails_helper"

RSpec.describe ShareeAvatarsComponent, type: :component do
  let(:creator) { create(:user) }
  let(:organization) { create(:organization, users: [ creator ]) }
  let(:list) { create(:list, organization: organization, creator: creator) }

  # Target organizations that will receive shares
  let(:target_org) { create(:organization, name: "test_org") }
  let!(:target_user) { create(:user, organizations: [ target_org ]) }

  context "when there are no shares" do
    it "does not render" do
      result = render_inline(described_class.new(list: list))
      expect(result.css(".flex")).not_to be_present
    end
  end

  context "with shares in different states" do
    it "renders pending share with correct tooltip" do
      create(:share,
        creator: creator,
        source_organization: organization,
        target_organization: target_org,
        shareable: list,
        status: :pending
      )

      result = render_inline(described_class.new(list: list))

      expect(result.css(".opacity-50")).to be_present
      expect(result.css(".tooltip")).to be_present
      expect(result.css("[data-tip]").first['data-tip']).to eq(
        I18n.t("sharee_avatars_component.pending_tooltip", user: "test_org")
      )
    end

    it "renders accepted share with correct tooltip" do
      create(:share,
        creator: creator,
        source_organization: organization,
        target_organization: target_org,
        shareable: list,
        status: :accepted
      )

      result = render_inline(described_class.new(list: list))

      expect(result.css(".opacity-50")).not_to be_present
      expect(result.css(".tooltip")).to be_present
      expect(result.css("[data-tip]").first['data-tip']).to eq(
        I18n.t("sharee_avatars_component.accepted_tooltip", user: "test_org")
      )
    end
  end

  context "with multiple shares" do
    it "renders all shares in correct order" do
      # Create multiple target organizations
      target_orgs = Array.new(3) do |i|
        org = create(:organization, name: "org#{i}")
        create(:user, organizations: [ org ]) # Ensure each org has at least one user
        org
      end

      # Create shares with each target organization
      shares = target_orgs.map do |org|
        create(:share,
          creator: creator,
          source_organization: organization,
          target_organization: org,
          shareable: list,
          status: :accepted
        )
      end

      result = render_inline(described_class.new(list: list))

      expect(result.css(".flex")).to be_present
      # Update to check for avatar-wrapper instead of .avatar since that's what our template now uses
      expect(result.css(".avatar-wrapper").count).to eq(3)
      expect(result.css("[data-tip]").count).to eq(3)

      target_orgs.each_with_index do |org, index|
        tooltip = I18n.t("sharee_avatars_component.accepted_tooltip", user: org.name)
        expect(result.css("[data-tip]")[index]['data-tip']).to eq(tooltip)
      end
    end
  end

  context "when organization has no name" do
    let(:nameless_org) { create(:organization, name: "") }
    let!(:nameless_org_user) { create(:user, organizations: [ nameless_org ]) }

    it "falls back to a placeholder name for tooltip" do
      create(:share,
        creator: creator,
        source_organization: organization,
        target_organization: nameless_org,
        shareable: list,
        status: :accepted
      )

      result = render_inline(described_class.new(list: list))

      expect(result.css("[data-tip]").first['data-tip']).to eq(
        I18n.t("sharee_avatars_component.accepted_tooltip", user: "Unknown Organization")
      )
    end
  end
end
