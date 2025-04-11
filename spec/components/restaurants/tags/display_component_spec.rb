require 'rails_helper'

RSpec.describe Restaurants::Tags::DisplayComponent, type: :component do
  include Rails.application.routes.url_helpers

  # Fix the tag_list to be a string instead of an array
  let(:tags) { 'italian, pizza' }
  let(:container_classes) { 'custom-class' }

  # Use instance_double instead of create to avoid factory issues
  let(:restaurant) do
    instance_double("Restaurant",
      id: 1,
      tags: [ 'italian', 'pizza' ],
      tag_list: tags
    )
  end

  let(:component) { described_class.new(record: restaurant, container_classes: container_classes) }

  before do
    # Add stub for dom_id to prevent issues with instance_double
    allow_any_instance_of(described_class).to receive(:dom_id).with(restaurant, :tags).and_return('restaurant_1_tags')
    allow_any_instance_of(described_class).to receive(:current_locale).and_return('en')
    # Stub the edit path helper
    allow_any_instance_of(described_class).to receive(:edit_restaurant_tags_path)
      .with(restaurant_id: restaurant.id, locale: 'en')
      .and_return("/restaurants/1/tags/edit")
  end

  describe 'rendering' do
    it 'renders the component container with custom classes' do
      render_inline(component)
      expect(page).to have_css("div.#{container_classes}")
    end

    it 'renders the title' do
      render_inline(component)
      expect(page).to have_content('Tags')
    end

    it 'wraps content in a turbo frame with correct ID' do
      render_inline(component)
      expect(page).to have_css("turbo-frame#restaurant_1_tags")
    end
  end

  describe 'edit button' do
    context 'in web app' do
      before do
        allow_any_instance_of(described_class).to receive(:helpers)
          .and_return(double(hotwire_native_app?: false))
      end

      it 'renders edit link with frame target' do
        render_inline(component)
        expect(page).to have_css("a[data-turbo-frame='restaurant_1_tags']")
      end
    end

    context 'in native app' do
      before do
        allow_any_instance_of(described_class).to receive(:helpers)
          .and_return(double(hotwire_native_app?: true))
      end

      it 'renders edit link with _top frame target' do
        render_inline(component)
        expect(page).to have_css('a[data-turbo-frame="_top"]')
      end
    end
  end

  describe 'tags display' do
    context 'when restaurant has tags' do
      it 'displays all tags' do
        render_inline(component)
        tags.split(', ').each do |tag|
          expect(page).to have_content(tag)
        end
      end

      it 'renders tags with correct styling' do
        render_inline(component)
        expect(page).to have_css('.bg-primary-100.text-primary-800.rounded-full', count: tags.split(', ').length)
      end
    end

    context 'when restaurant has no tags' do
      let(:restaurant) do
        instance_double("Restaurant",
          id: 1,
          tags: [],
          tag_list: ''
        )
      end

      let(:component) { described_class.new(record: restaurant, container_classes: container_classes) }

      before do
        allow_any_instance_of(described_class).to receive(:dom_id).with(restaurant, :tags).and_return('restaurant_1_tags')
        allow_any_instance_of(described_class).to receive(:edit_restaurant_tags_path)
          .with(restaurant_id: restaurant.id, locale: 'en')
          .and_return("/restaurants/1/tags/edit")
        allow_any_instance_of(described_class).to receive(:helpers)
          .and_return(double(hotwire_native_app?: false))
      end

      it 'displays add tags button' do
        render_inline(component)
        expect(page).to have_content('Add tags')
        expect(page).to have_css('.border-dashed')
      end
    end
  end

  describe '#frame_id' do
    it 'returns the correct dom id' do
      expect(component.frame_id).to eq('restaurant_1_tags')
    end
  end

  describe '#has_tags?' do
    context 'when restaurant has tags' do
      it 'returns true' do
        expect(component.has_tags?).to be true
      end
    end

    context 'when restaurant has no tags' do
      let(:restaurant) do
        instance_double("Restaurant",
          id: 1,
          tags: [],
          tag_list: ''
        )
      end

      it 'returns false' do
        expect(component.has_tags?).to be false
      end
    end
  end

  describe '#edit_path' do
    let(:expected_path) { "/restaurants/1/tags/edit" }

    before do
      # Use allow on the specific component instance
      allow(component).to receive(:helpers)
        .and_return(double(
          hotwire_native_app?: false,
          edit_restaurant_tags_path: expected_path
        ))
      allow(component).to receive(:edit_restaurant_tags_path)
        .with(restaurant_id: restaurant.id, locale: 'en')
        .and_return(expected_path)
    end

    it 'renders link with correct path' do
      render_inline(component)
      expect(page).to have_link(href: expected_path)
    end
  end
end
