require "rails_helper"

RSpec.describe Lists::HeaderComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers
    allow(Rails.application.routes).to receive(:url_for).and_return("/")

    # Mock the edit_list_path method to handle both object and hash arguments
    allow_any_instance_of(Lists::HeaderComponent).to receive(:edit_list_path) do |_, arg|
      id = arg.is_a?(Hash) ? arg[:id] : arg.id
      "/lists/#{id}/edit"
    end
  end

  let(:current_user) { double('User') }
  let(:organization) { double('Organization', id: 1, name: "Org Name") }
  let(:shares) { double('ActiveRecord::Relation') }
  let(:list) { double('List',
    id: 1,
    organization: organization,
    name: "My List",
    visibility: "discoverable"
  ) }

  before do
    # Mock organization methods
    allow(list).to receive(:shared?).and_return(false)
    allow(list).to receive(:editable_by?).with(current_user).and_return(true)
    # Allow user to be part of organization
    allow(current_user).to receive(:organizations).and_return(double(exists?: true, pluck: [ organization.id ]))

    # Mock shares for ShareeAvatarsComponent
    allow(list).to receive(:shares).and_return(shares)
    allow(shares).to receive(:includes).and_return([])

    # Mock ShareeAvatarsComponent
    allow_any_instance_of(ShareeAvatarsComponent).to receive(:render_in).and_return("<div class='mt-2'>Mock ShareeAvatarsComponent</div>".html_safe)

    # Mock AvatarComponent
    allow_any_instance_of(AvatarComponent).to receive(:render_in).and_return("<div class='avatar'>Org Name</div>".html_safe)

    # Add stub for I18n.t
    allow(I18n).to receive(:t).with(anything) do |arg|
      if arg.to_s.start_with?('lists.visibility.')
        "#{arg.to_s.split('.').last.capitalize}"
      else
        "Translated Text"
      end
    end
  end

  context "when viewing a personal list" do
    before do
      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "renders list name and visibility" do
      expect(page).to have_content("My List")
      expect(page).to have_selector(".badge", text: "Discoverable")
    end

    it "does not render owner avatar" do
      expect(page).not_to have_selector(".avatar")
    end

    it "renders edit button" do
      expect(page).to have_link(href: /\/lists\/#{list.id}\/edit/)
      expect(page).to have_selector("svg") # Heroicon
    end
  end

  context "when viewing a shared list" do
    before do
      allow(list).to receive(:shared?).and_return(true)
    end

    it "renders the owner avatar" do
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".avatar")
    end

    it "does not render edit button for non-editable lists" do
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).not_to have_link(href: /\/lists\/#{list.id}\/edit/)
    end
  end

  context "when user is not part of the organization" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: false, pluck: []))
      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "doesn't render the sharee avatars component" do
      expect(page).not_to have_selector(".mt-2") # The container for ShareeAvatarsComponent
    end
  end

  context "when user is part of the organization" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: true, pluck: [ organization.id ]))
      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "renders the sharee avatars component" do
      expect(page).to have_selector(".mt-2") # The container for ShareeAvatarsComponent
    end
  end

  describe "visibility badge styling" do
    it "applies neutral style for personal lists" do
      allow(list).to receive(:visibility).and_return("personal")
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".badge-neutral")
    end

    it "applies info style for discoverable lists" do
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".badge-info")
    end
  end
end
