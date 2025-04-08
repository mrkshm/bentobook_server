require "rails_helper"

RSpec.describe Lists::ActionsComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers
    allow(Rails.application.routes).to receive(:url_for).and_return("/")

    # Mock path helpers
    allow_any_instance_of(Lists::ActionsComponent).to receive(:share_list_path).and_return("/lists/1/share")
    allow_any_instance_of(Lists::ActionsComponent).to receive(:export_list_path).and_return("/lists/1/export")
    allow_any_instance_of(Lists::ActionsComponent).to receive(:edit_list_path).and_return("/lists/1/edit")
    allow_any_instance_of(Lists::ActionsComponent).to receive(:lists_path).and_return("/lists")

    # Mock translations more precisely to catch the exact keys used
    translations = {
      'lists.actions_component.share' => 'Share',
      'lists.actions_component.export' => 'Export',
      'lists.actions_component.export_markdown' => 'Export Markdown',
      'lists.actions_component.export_email' => 'Export Email',
      'lists.actions_component.markdown_exported' => 'Markdown Exported',
      'common.edit' => 'Edit',
      'common.back' => 'Back'
    }

    allow(I18n).to receive(:t) do |key, **options|
      translations[key.to_s] || key.to_s
    end

    # Mock heroicon helper
    allow_any_instance_of(Lists::ActionsComponent).to receive(:heroicon) do |_, name, options|
      "<svg class='#{options[:options][:class]}'>#{name}</svg>".html_safe
    end
  end

  let(:current_user) { double('User') }
  let(:owner_org) { double('Organization', id: 1, name: "Owner Org") }
  let(:other_org) { double('Organization', id: 2, name: "Other Org") }

  # Setup shared list with basic attributes
  let(:list) { double('List',
    id: 1,
    organization: owner_org,
    name: "Test List",
    shares: double('ActiveRecord::Relation')
  ) }

  context "when user is in the owner organization" do
    before do
      # User is in the owner organization
      allow(current_user).to receive(:organizations).and_return(double(exists?: true, pluck: [ owner_org.id ]))

      # List is editable by the user
      allow(list).to receive(:editable_by?).with(current_user).and_return(true)

      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "shows all actions" do
      expect(page).to have_link(href: "/lists/1/share") # Share button
      expect(page).to have_link(href: "/lists/1/edit")  # Edit button
      expect(page).to have_selector("label", text: "Export")
      expect(page).to have_link(href: "/lists") # Back button
    end
  end

  context "when user is in a shared organization with view permission" do
    before do
      # User is not in the owner organization
      allow(current_user).to receive(:organizations).and_return(double(exists?: false, pluck: [ other_org.id ]))

      # List is not editable by the user
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)

      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "shows only export and back actions" do
      expect(page).not_to have_link(href: "/lists/1/share") # No Share button
      expect(page).not_to have_link(href: "/lists/1/edit")  # No Edit button
      expect(page).to have_selector("label", text: "Export")
      expect(page).to have_link(href: "/lists") # Back button
    end
  end

  context "when user is in a shared organization with edit permission" do
    before do
      # User is not in the owner organization but has edit permission
      allow(current_user).to receive(:organizations).and_return(double(exists?: false, pluck: [ other_org.id ]))

      # List is editable by the user (through a share with edit permission)
      allow(list).to receive(:editable_by?).with(current_user).and_return(true)

      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "shows edit, export and back actions but not share" do
      expect(page).not_to have_link(href: "/lists/1/share") # No Share button
      expect(page).to have_link(href: "/lists/1/edit")      # Edit button
      expect(page).to have_selector("label", text: "Export")
      expect(page).to have_link(href: "/lists") # Back button
    end
  end
end
