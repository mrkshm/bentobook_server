require "rails_helper"

RSpec.describe Lists::SharedActionsComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers
    allow(Rails.application.routes).to receive(:url_for).and_return("/")

    # Mock path helpers
    allow_any_instance_of(Lists::SharedActionsComponent).to receive(:import_all_list_list_restaurants_path).and_return("/lists/1/list_restaurants/import_all")
    allow_any_instance_of(Lists::SharedActionsComponent).to receive(:new_list_list_restaurant_path).and_return("/lists/1/list_restaurants/new")
    allow_any_instance_of(Lists::SharedActionsComponent).to receive(:edit_list_list_restaurants_path).and_return("/lists/1/list_restaurants/edit")
    allow_any_instance_of(Lists::SharedActionsComponent).to receive(:remove_share_list_path).and_return("/lists/1/remove_share")

    # Mock translations
    translations = {
      'components.shared_list_actions_component.shared_by' => 'Shared by %{owner}',
      'components.shared_list_actions_component.import_all' => 'Import All',
      'components.shared_list_actions_component.confirm_import_all' => 'Add all restaurants to your collection?',
      'components.shared_list_actions_component.add_restaurant' => 'Add Restaurant',
      'components.shared_list_actions_component.manage_restaurants' => 'Manage Restaurants',
      'components.shared_list_actions_component.actions' => 'Actions',
      'components.shared_list_actions_component.remove_from_my_lists' => 'Remove from My Lists',
      'components.shared_list_actions_component.confirm_remove' => 'Are you sure you want to remove this list?'
    }

    allow(I18n).to receive(:t) do |key, **options|
      if key == 'components.shared_list_actions_component.shared_by' && options[:owner]
        "Shared by #{options[:owner]}"
      else
        translations[key.to_s] || key.to_s
      end
    end

    # Mock heroicon helper
    allow_any_instance_of(Lists::SharedActionsComponent).to receive(:heroicon) do |_, name, options|
      "<svg class='#{options[:options][:class]}'>#{name}</svg>".html_safe
    end
  end

  # Mock organization and owner user
  let(:owner_user) { double('User', id: 3) }
  let(:owner_profile) { double('Profile', display_name: 'Owner Name') }
  let(:owner_org) { double('Organization', id: 1) }

  let(:current_user) { double('User', id: 4) }
  let(:current_org) { double('Organization', id: 2) }

  # Setup shared list with basic attributes and properly mock owner relationship
  let(:list) do
    double('List',
      id: 1,
      organization: owner_org,
      owner: owner_org
    )
  end

  # Mock the relationship between list.restaurants and the where clause
  let(:list_restaurants) { double('ActiveRecord::Relation') }
  let(:where_relation) { double('ActiveRecord::Relation') }

  # Define Current.organization for import test and set up the restaurants relation
  before do
    # Mock the list.restaurants method
    allow(list).to receive(:restaurants).and_return(list_restaurants)

    # Mock Current.organization
    stub_const("Current", double('Current'))
    allow(Current).to receive(:organization).and_return(current_org)

    # Mock organization's restaurants
    allow(current_org).to receive(:restaurants).and_return(where_relation)
    allow(where_relation).to receive(:where).with(any_args).and_return(where_relation)

    # Mock profile display name - organization needs to return a profile with display_name
    allow(owner_org).to receive(:profile).and_return(owner_profile)
  end

  def render_component
    render_inline(described_class.new(list: list, current_user: current_user))
  end

  context "when rendering" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: false))
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)
      allow(list_restaurants).to receive(:exists?).and_return(false)
    end

    it "shows owner information" do
      render_component
      expect(page).to have_content("Shared by Owner Name")
    end
  end

  context "when there are restaurants to import" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: false))
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)

      # Mock restaurants that can be imported
      allow(list_restaurants).to receive(:exists?).with(any_args).and_return(true)
    end

    it "shows import all button" do
      render_component
      expect(page).to have_button('Import All')
    end
  end

  context "when all restaurants are already imported" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: false))
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)

      # Mock no restaurants to import
      allow(list_restaurants).to receive(:exists?).with(any_args).and_return(false)
    end

    it "does not show import all button" do
      render_component
      expect(page).not_to have_button('Import All')
    end
  end

  context "when user has edit permissions" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: true))
      allow(list).to receive(:editable_by?).with(current_user).and_return(true)
      allow(list_restaurants).to receive(:exists?).with(any_args).and_return(false)
    end

    it "shows edit actions" do
      render_component
      expect(page).to have_link('Add Restaurant')
      expect(page).to have_link('Manage Restaurants')
    end
  end

  context "when user does not have edit permissions" do
    before do
      allow(current_user).to receive(:organizations).and_return(double(exists?: false))
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)
      allow(list_restaurants).to receive(:exists?).with(any_args).and_return(false)
    end

    it "does not show edit actions but shows actions dropdown" do
      render_component

      expect(page).not_to have_link('Add Restaurant')
      expect(page).not_to have_link('Manage Restaurants')
      expect(page).to have_selector("label", text: "Actions")

      # Use a more general test for the dropdown content's existence
      expect(page).to have_selector("ul.dropdown-content")
    end
  end
end
