require "rails_helper"

RSpec.describe Lists::DetailComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers for nested components
    allow_any_instance_of(Lists::HeaderComponent).to receive(:edit_list_path) do |_, list|
      "/lists/#{list.id}/edit"
    end

    # Mock Current.organization to return current_organization
    allow(Current).to receive(:organization).and_return(current_organization)
  end

  let(:current_user) { double('User') }
  let(:current_organization) { double('Organization', id: 1, name: "Current Organization") }
  let(:list_organization) { current_organization } # Set organization to current by default
  let(:statistics) { double('ListStatistics') }
  let(:user_organizations) { double('Organizations') }

  # Important: Make list respond to methods needed by dom_id
  let(:list) do
    double('List',
      id: 1,
      organization: list_organization,
      name: "Test List",
      description: nil,
      # Add methods needed by dom_id
      to_key: [ 1 ],
      to_model: double(model_name: double(param_key: 'list')),
      # For description test
      description: nil,
      # For header component
      shared?: false,
      visibility: "personal"
    )
  end

  before do
    # Setup common mocks
    allow(ListStatistics).to receive(:new).with(list: list, user: current_user).and_return(statistics)
    
    # Make sure editable_by_organization? doesn't cause stack overflow
    allow(list).to receive(:editable_by_organization?).with(current_organization) do
      # Lists owned by current_organization are editable by it
      list.organization.id == current_organization.id
    end
    
    # Add mock for the editable_by? method used by ActionsComponent
    allow(list).to receive(:editable_by?).with(current_user).and_return(true)

    # Add mocks for current_user.organizations used by ActionsComponent
    allow(current_user).to receive(:organizations).and_return(user_organizations)
    allow(user_organizations).to receive(:exists?).with(id: list_organization.id).and_return(true)
    allow(user_organizations).to receive(:pluck).with(:id).and_return([ list_organization.id ])

    # Mock nested components - prevent them from rendering
    allow_any_instance_of(Lists::HeaderComponent).to receive(:render_in).and_return("<div class='header'>Header</div>".html_safe)
    allow_any_instance_of(Lists::ActionsComponent).to receive(:render_in).and_return("<div class='actions'>Actions</div>".html_safe)
    allow_any_instance_of(Lists::StatsComponent).to receive(:render_in).and_return("<div class='stats'>Stats</div>".html_safe)
  end

  it "renders a list card" do
    render_inline(described_class.new(list: list, current_user: current_user))
    expect(page).to have_selector(".card")
  end

  it "renders list description when present" do
    allow(list).to receive(:description).and_return("Test description")
    render_inline(described_class.new(list: list, current_user: current_user))
    expect(page).to have_text("Test description")
  end

  it "sets correct permissions for owner organization" do
    # Now list.organization == current_organization will work properly
    component = described_class.new(list: list, current_user: current_user)
    expect(component.send(:permissions)).to include(
      can_edit: true,
      can_delete: true
    )
  end

  context "with shared list" do
    let(:other_organization) { double('Organization', id: 2, name: "Other Organization") }

    before do
      # Set list organization to the other org
      allow(list).to receive(:organization).and_return(other_organization)
      
      # Override the previous mock for editable_by_organization?
      allow(list).to receive(:editable_by_organization?).with(current_organization).and_return(false)
    end

    it "sets correct permissions for viewer organization" do
      component = described_class.new(list: list, current_user: current_user)
      expect(component.send(:permissions)).to include(
        can_edit: false,
        can_delete: false
      )
    end

    it "marks list as shared" do
      component = described_class.new(list: list, current_user: current_user)
      expect(component.send(:is_shared)).to be true
    end
  end

  context "when list belongs to current organization" do
    it "does not mark list as shared" do
      component = described_class.new(list: list, current_user: current_user)
      expect(component.send(:is_shared)).to be false
    end
  end
end
