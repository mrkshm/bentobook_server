# frozen_string_literal: true

require "rails_helper"

RSpec.describe VisitCardComponent, type: :component do
  let(:restaurant) { double("Restaurant", name: "Pizza Palace") }
  let(:visit) do
    double("Visit",
      id: 1,
      restaurant: restaurant,
      date: Date.new(2024, 3, 15),
      title: "Birthday Dinner",
      notes: "Great pizza and service",
      rating: 4,
      contacts: [],
      images: []
    )
  end

  before do
    allow_any_instance_of(VisitCardComponent).to receive(:visit_path).and_return("/visits/1")
    
    # Create a proper mock for RatingsComponent
    ratings_component = double("RatingsComponent")
    allow(ratings_component).to receive(:render_in).and_return("★★★★")
    allow(RatingsComponent).to receive(:new).and_return(ratings_component)
  end

  context "with basic rendering" do
    subject(:component) { described_class.new(visit: visit) }

    it "renders the restaurant name" do
      render_inline(component)
      expect(page).to have_content("Pizza Palace")
    end

    it "renders the formatted date" do
      render_inline(component)
      expect(page).to have_content("March 15, 2024")
    end

    it "renders the title" do
      render_inline(component)
      expect(page).to have_content("Birthday Dinner")
    end

    it "renders the notes" do
      render_inline(component)
      expect(page).to have_content("Great pizza and service")
    end
  end

  context "with link_to_show option" do
    it "renders as a link when link_to_show is true" do
      component = described_class.new(visit: visit, link_to_show: true)
      render_inline(component)
      expect(page).to have_link(href: "/visits/1")
    end

    it "renders as a div when link_to_show is false" do
      component = described_class.new(visit: visit, link_to_show: false)
      render_inline(component)
      expect(page).not_to have_link(href: "/visits/1")
      expect(page).to have_css("div.card")
    end
  end

  context "with optional content" do
    let(:visit_without_optional) do
      double("Visit",
        id: 2,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: nil,
        notes: nil,
        rating: 4,
        contacts: [],
        images: []
      )
    end

    subject(:component) { described_class.new(visit: visit_without_optional) }

    it "does not render title section when title is nil" do
      render_inline(component)
      expect(page).not_to have_css("h3.font-medium")
    end

    it "does not render notes section when notes are nil" do
      render_inline(component)
      expect(page).not_to have_css('p[class="text-base-content/70"]')
    end

    it "still renders required content" do
      render_inline(component)
      expect(page).to have_content("Pizza Palace")
      expect(page).to have_content("March 15, 2024")
    end
  end

  context "with contacts" do
    let(:contact1) { double("Contact", id: 1, name: "John Doe") }
    let(:contact2) { double("Contact", id: 2, name: "Jane Smith") }
    let(:visit_with_contacts) do
      double("Visit",
        id: 3,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: "Dinner",
        notes: "Nice",
        rating: 4,
        contacts: [contact1, contact2],
        images: []
      )
    end

    before do
      allow_any_instance_of(VisitCardComponent).to receive(:contact_path).and_return("/contacts/1")
      
      # Mock Contact objects with complete respond_to? handling
      [contact1, contact2].each do |contact|
        allow(contact).to receive(:is_a?).with(anything).and_return(false)
        allow(contact).to receive(:is_a?).with(Contact).and_return(true)
        allow(contact).to receive(:is_a?).with(User).and_return(false)
        
        # Handle all possible respond_to? calls
        allow(contact).to receive(:respond_to?).with(anything).and_return(false)
        allow(contact).to receive(:respond_to?).with(:avatar).and_return(true)
        allow(contact).to receive(:respond_to?).with(:name).and_return(true)
        allow(contact).to receive(:respond_to?).with(:display_name).and_return(false)
        
        allow(contact).to receive(:avatar).and_return(nil)
      end

      # Mock AvatarComponent
      avatar_component = double("AvatarComponent")
      allow(avatar_component).to receive(:render_in).and_return("<div class='avatar-mock'></div>".html_safe)
      allow(AvatarComponent).to receive(:new).and_return(avatar_component)
    end

    it "renders avatars for each contact" do
      component = described_class.new(visit: visit_with_contacts)
      render_inline(component)
      
      expect(AvatarComponent).to have_received(:new).with(
        user: contact1,
        size: :small,
        tooltip: "John Doe"
      )
      
      expect(AvatarComponent).to have_received(:new).with(
        user: contact2,
        size: :small,
        tooltip: "Jane Smith"
      )
    end

    it "renders contact container when contacts exist" do
      component = described_class.new(visit: visit_with_contacts)
      render_inline(component)
      expect(page).to have_css("div.flex.flex-wrap.gap-2")
    end

    it "does not render contact container when no contacts exist" do
      visit_without_contacts = double("Visit",
        id: 4,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: "Dinner",
        notes: "Nice",
        rating: 4,
        contacts: [],
        images: []
      )
      
      component = described_class.new(visit: visit_without_contacts)
      render_inline(component)
      expect(page).not_to have_css("div.mt-4")
    end
  end

  describe "#render_contacts" do
    let(:contact1) { double("Contact", id: 1, name: "John Doe") }
    let(:contact2) { double("Contact", id: 2, name: "Jane Smith") }
    let(:restaurant) { double("Restaurant", name: "Pizza Palace") }
    
    before do
      allow_any_instance_of(VisitCardComponent).to receive(:contact_path).and_return("/contacts/1")
      
      # Mock Contact objects with complete respond_to? handling
      [contact1, contact2].each do |contact|
        allow(contact).to receive(:is_a?).with(anything).and_return(false)
        allow(contact).to receive(:is_a?).with(Contact).and_return(true)
        allow(contact).to receive(:is_a?).with(User).and_return(false)
        
        # Handle all possible respond_to? calls
        allow(contact).to receive(:respond_to?).with(anything).and_return(false)
        allow(contact).to receive(:respond_to?).with(:avatar).and_return(true)
        allow(contact).to receive(:respond_to?).with(:name).and_return(true)
        allow(contact).to receive(:respond_to?).with(:display_name).and_return(false)
        
        allow(contact).to receive(:avatar).and_return(nil)
      end

      # Mock AvatarComponent
      avatar_component = double("AvatarComponent")
      allow(avatar_component).to receive(:render_in).and_return("<div class='avatar-mock'></div>".html_safe)
      allow(AvatarComponent).to receive(:new).and_return(avatar_component)
    end

    let(:visit_without_contacts) do
      double("Visit",
        id: 4,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: "Dinner",
        notes: "Nice",
        rating: 4,
        contacts: [],
        images: []
      )
    end

    let(:visit_with_contacts) do
      double("Visit",
        id: 3,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: "Dinner",
        notes: "Nice",
        rating: 4,
        contacts: [contact1, contact2],
        images: []
      )
    end

    let(:visit_with_one_contact) do
      double("Visit",
        id: 5,
        restaurant: restaurant,
        date: Date.new(2024, 3, 15),
        title: "Dinner",
        notes: "Nice",
        rating: 4,
        contacts: [contact1],
        images: []
      )
    end

    it "returns nil when no contacts exist" do
      component = described_class.new(visit: visit_without_contacts)
      render_inline(component)
      expect(page).not_to have_css("div.mt-4")
    end

    it "renders contacts with correct HTML structure" do
      component = described_class.new(visit: visit_with_contacts)
      render_inline(component)
      
      expect(page).to have_css("div.flex.flex-wrap.gap-2")
      expect(page).to have_css("div.avatar-mock", count: 2)
      expect(page).to have_link(href: "/contacts/1", count: 2)
    end

    it "creates avatar components with correct parameters" do
      component = described_class.new(visit: visit_with_one_contact)
      render_inline(component)
      
      expect(AvatarComponent).to have_received(:new).with(
        user: contact1,
        size: :small,
        tooltip: "John Doe"
      )
    end

    it "creates links with correct paths" do
      component = described_class.new(visit: visit_with_one_contact)
      render_inline(component)
      
      expect(page).to have_link(href: "/contacts/1")
    end
  end
end
