require 'rails_helper'

RSpec.describe Restaurants::CardComponent, type: :component do
  let(:cuisine_type) { double('CuisineType', name: 'Italian') }
  let(:tag1) { double('Tag', name: 'Pizza') }
  let(:tag2) { double('Tag', name: 'Family-friendly') }
  let(:restaurant) do
    double('Restaurant',
      id: 1,
      name: 'Pizza Palace',
      cuisine_type: cuisine_type,
      street_number: '123',
      street: 'Main St',
      postal_code: '12345',
      city: 'New York',
      state: 'NY',
      country: 'USA',
      phone_number: '555-1234',
      url: 'https://pizzapalace.com',
      tags: [ tag1, tag2 ],
      visit_count: 3,
      # Add these missing methods that are called by the component
      price_level: 2,
      combined_street_number: '123',
      combined_street: 'Main St',
      combined_postal_code: '12345',
      combined_city: 'New York',
      combined_state: 'NY',
      combined_country: 'USA'
    )
  end

  subject(:component) { described_class.new(restaurant: restaurant) }

  before do
    allow_any_instance_of(Restaurants::CardComponent).to receive(:restaurant_path).and_return('/restaurants/1')
    # Only mock the t helper for other calls, not for cuisine type
    allow_any_instance_of(Restaurants::CardComponent).to receive(:t).with(anything) do |_, arg|
      if arg.to_s.start_with?('cuisine_types.')
        arg.to_s
      else
        "Translated Text"
      end
    end
  end

  it 'renders the restaurant name' do
    render_inline(component)
    expect(page).to have_content('Pizza Palace')
  end

  it 'renders the cuisine type' do
    render_inline(component)
    expect(page).to have_content('Italian')
  end

  it 'renders the full address' do
    render_inline(component)
    expect(page).to have_content('123 Main St')
    expect(page).to have_content('12345 New York')
    expect(page).to have_content('NY')
    expect(page).to have_content('USA')
  end

  it 'renders the phone number' do
    render_inline(component)
    expect(page).to have_content('555-1234')
  end

  it 'renders the website URL' do
    render_inline(component)
    expect(page).to have_link('https://pizzapalace.com', href: 'https://pizzapalace.com')
  end

  it 'renders the tags' do
    render_inline(component)
    expect(page).to have_content('Pizza')
    expect(page).to have_content('Family-friendly')
  end

  it 'renders a link to the restaurant details page' do
    render_inline(component)
    expect(page).to have_link(href: '/restaurants/1')
  end

  it 'renders the visit count badge when visits exist' do
    render_inline(component)
    expect(page).to have_css('.badge', text: '3')
  end

  context 'when some fields are missing' do
    let(:restaurant) do
      double('Restaurant',
        id: 2,
        name: 'Burger Joint',
        cuisine_type: nil,
        street_number: '456',
        street: 'Oak Ave',
        postal_code: nil,
        city: 'Chicago',
        state: nil,
        country: 'USA',
        phone_number: nil,
        url: nil,
        tags: [],
        visit_count: 0,
        # Add these missing methods
        price_level: 1,
        combined_street_number: '456',
        combined_street: 'Oak Ave',
        combined_postal_code: nil,
        combined_city: 'Chicago',
        combined_state: nil,
        combined_country: 'USA'
      )
    end

    it 'does not render missing fields' do
      render_inline(component)
      expect(page).not_to have_content('Italian')
      expect(page).not_to have_content('postal_code')
      expect(page).not_to have_content('state')
      expect(page).not_to have_content('phone number')
      expect(page).not_to have_content('website')
      expect(page).not_to have_css('.badge')
    end
  end

  describe '#formatted_address' do
    it 'returns the correctly formatted address' do
      expect(component.send(:formatted_address)).to eq('123 Main St, 12345 New York, NY, USA')
    end

    context 'when some address fields are missing' do
      let(:restaurant) do
        double('Restaurant',
          combined_street_number: '789',
          combined_street: 'Elm St',
          combined_postal_code: nil,
          combined_city: 'Los Angeles',
          combined_state: nil,
          combined_country: 'USA',
          visit_count: 0
        )
      end

      it 'formats the address without missing fields' do
        expect(component.send(:formatted_address)).to eq('789 Elm St, Los Angeles, USA')
      end
    end
  end
end
