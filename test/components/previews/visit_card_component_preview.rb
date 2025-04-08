# frozen_string_literal: true

class Visits::CardComponentPreview < ViewComponent::Preview
  def default
    visit = Visit.first || create_sample_visit
    render Visits::CardComponent.new(visit: visit)
  end

  private

  def create_sample_visit
    restaurant = Restaurant.first || Restaurant.create!(name: "Sample Restaurant", organization: Organization.first)
    Visit.create!(
      restaurant: restaurant,
      date: Date.today,
      title: "Sample Visit",
      notes: "This is a sample visit for preview purposes.",
      rating: 4,
      organization: restaurant.organization
    )
  end
end
