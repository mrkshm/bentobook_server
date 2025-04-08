# frozen_string_literal: true

require "rails_helper"

RSpec.describe Visits::CardComponent, type: :component do
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
      images: [],
      to_key: [ 1 ] # Add to_key method for dom_id
    )
  end

  before do
    allow_any_instance_of(Visits::CardComponent).to receive(:visit_path).and_return("/visits/1")
    allow_any_instance_of(Visits::CardComponent).to receive(:current_locale).and_return("en")

    # Create a proper mock for RatingComponent (not RatingsComponent)
    rating_component = double("RatingComponent")
    allow(rating_component).to receive(:render_in).and_return("★★★★")
    allow(Visits::RatingComponent).to receive(:new).and_return(rating_component)
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
        title: "",
        notes: "",
        rating: 4,
        contacts: [],
        images: [],
        to_key: [ 2 ] # Add to_key method for dom_id
      )
    end

    subject(:component) { described_class.new(visit: visit_without_optional) }

    it "does not render title section when title is empty" do
      # We need to stub the helper method in the component
      allow_any_instance_of(Visits::CardComponent).to receive(:has_title?).and_return(false)

      render_inline(component)
      expect(page).not_to have_css("div.text-md.font-medium")
    end

    it "does not render notes section when notes are empty" do
      # We need to stub the helper method in the component
      allow_any_instance_of(Visits::CardComponent).to receive(:has_notes?).and_return(false)

      render_inline(component)
      expect(page).not_to have_css("p.text-sm")
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
        contacts: [ contact1, contact2 ],
        images: [],
        to_key: [ 3 ] # Add to_key method for dom_id
      )
    end

    before do
      puts "DEBUG: Setting up contacts section"
      # Set up the helper method
      allow_any_instance_of(Visits::CardComponent).to receive(:has_contacts?).and_return(true)

      allow_any_instance_of(Visits::CardComponent).to receive(:contact_path).and_return("/contacts/1")

      # Mock Contact objects with complete respond_to? handling
      [ contact1, contact2 ].each do |contact|
        puts "DEBUG: Setting up mock for #{contact.name}"
        allow(contact).to receive(:is_a?).with(anything).and_return(false)
        allow(contact).to receive(:is_a?).with(Contact).and_return(true)
        allow(contact).to receive(:is_a?).with(User).and_return(false)

        # Handle all possible respond_to? calls for new avatar component
        allow(contact).to receive(:respond_to?).with(anything).and_return(false)
        allow(contact).to receive(:respond_to?).with(:avatar_medium).and_return(false)
        allow(contact).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
        allow(contact).to receive(:respond_to?).with(:profile).and_return(false)
        allow(contact).to receive(:respond_to?).with(:name).and_return(true)
        allow(contact).to receive(:respond_to?).with(:display_name).and_return(false)
        allow(contact).to receive(:respond_to?).with(:full_name).and_return(false)
      end

      # Mock AvatarComponent
      puts "DEBUG: Setting up AvatarComponent mock"
      avatar_component = double("AvatarComponent")
      allow(avatar_component).to receive(:render_in).and_return("<div class='avatar-mock'></div>".html_safe)
      allow(AvatarComponent).to receive(:new).and_return(avatar_component)
    end

    it "renders contacts when they exist" do
      component = described_class.new(visit: visit_with_contacts)
      render_inline(component)
      expect(page).to have_css("div.flex.-space-x-2.overflow-hidden")
      expect(AvatarComponent).to have_received(:new).with(
        user: contact1,
        size: :sm,
        tooltip: "John Doe"
      )
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
        images: [],
        to_key: [ 4 ] # Add to_key method for dom_id
      )

      # Set up the helper method
      allow_any_instance_of(Visits::CardComponent).to receive(:has_contacts?).and_return(false)

      component = described_class.new(visit: visit_without_contacts)
      render_inline(component)
      expect(page).not_to have_css("div.flex.-space-x-2.overflow-hidden")
    end
  end
end
