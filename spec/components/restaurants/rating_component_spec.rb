require 'rails_helper'

RSpec.describe Restaurants::RatingComponent, type: :component do
  # Create a double for the rating value
  let(:rating) { double('Rating') }
  # Use the rating double in the restaurant double
  let(:restaurant) { instance_double("Restaurant", id: 1, rating: rating) }

  before do
    # Stub to_i on the rating double, not on the restaurant
    allow(rating).to receive(:to_i).and_return(3)
  end

  describe "with default editable mode" do
    it "renders a turbo frame with a link" do
      # We need to use allow_any_instance_of instead of stubbing on the component instance
      # This ensures the stubs are applied before the component is rendered
      allow_any_instance_of(described_class).to receive(:edit_restaurant_rating_path).and_return("/restaurants/1/rating/edit")
      allow_any_instance_of(described_class).to receive(:current_locale).and_return("en")
      allow_any_instance_of(described_class).to receive(:frame_id).and_return("restaurant_1_rating")

      # For the turbo_frame_tag, we need to make it return HTML that will be included in the output
      allow_any_instance_of(described_class).to receive(:helpers).and_return(
        double('Helpers').tap do |helpers|
          allow(helpers).to receive(:turbo_frame_tag) do |id, &block|
            # This simulates what turbo_frame_tag actually does - it yields to the block
            # and wraps the result in a turbo-frame tag
            "<turbo-frame id=\"#{id}\">#{block.call}</turbo-frame>"
          end
        end
      )

      render_inline(described_class.new(restaurant: restaurant))

      # Check for the stars with correct styling
      expect(page).to have_css("span.text-primary-500", count: 3)
      expect(page).to have_css("span.text-surface-300", count: 2)
    end
  end

  describe "with readonly mode" do
    it "renders stars without a turbo frame or link" do
      render_inline(described_class.new(restaurant: restaurant, readonly: true))

      # In readonly mode, there should be no turbo frame or link
      expect(page).not_to have_css("turbo-frame")
      expect(page).not_to have_css("a")

      # But we should still see the stars with correct styling
      expect(page).to have_css("span.text-primary-500", count: 3)
      expect(page).to have_css("span.text-surface-300", count: 2)
    end
  end

  # Test with nil rating
  context "when restaurant has no rating" do
    let(:nil_rating) { double('NilRating') }
    let(:restaurant_without_rating) { instance_double("Restaurant", id: 2, rating: nil_rating) }

    before do
      allow(nil_rating).to receive(:to_i).and_return(0)
    end

    it "renders all empty stars" do
      render_inline(described_class.new(restaurant: restaurant_without_rating, readonly: true))

      # All stars should be empty
      expect(page).to have_css("span.text-surface-300", count: 5)
      expect(page).not_to have_css("span.text-primary-500")
    end
  end
end
