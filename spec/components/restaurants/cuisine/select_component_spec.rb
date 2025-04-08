require 'rails_helper'

RSpec.describe Restaurants::Cuisine::SelectComponent, type: :component do
  let(:cuisine_types) do
    [
      double('CuisineType',
        id: 1,
        name: 'italian',
        translated_name: 'Italian'
      ),
      double('CuisineType',
        id: 2,
        name: 'japanese',
        translated_name: 'Japanese'
      ),
      double('CuisineType',
        id: 3,
        name: 'mexican',
        translated_name: 'Mexican'
      )
    ]
  end

  before do
    # Add translations
    allow(I18n).to receive(:t).with(any_args) do |key, **options|
      case key
      when 'labels.cuisine_type'
        "Cuisine Type"
      when 'placeholders.select_cuisine_type'
        "Select a cuisine type"
      when 'italian'
        "Italian"
      when 'japanese'
        "Japanese"
      when 'mexican'
        "Mexican"
      else
        key
      end
    end
  end

  describe "with a form" do
    let(:restaurant) { double('Restaurant', cuisine_type: nil) }
    let(:form) do
      double('form').tap do |f|
        allow(f).to receive(:label).and_return("<label></label>")
        allow(f).to receive(:text_field).and_return("<input type='text' />")
        allow(f).to receive(:hidden_field).and_return("<input type='hidden' />")
        allow(f).to receive(:object).and_return(restaurant)
      end
    end

    let(:component) { described_class.new(form: form, cuisine_types: cuisine_types) }

    it 'renders the component' do
      render_inline(component)
      expect(page).to have_css('div[data-controller="cuisine-type-select"]')
    end

    it 'renders the cuisine type input field' do
      expect(form).to receive(:text_field).with(:cuisine_type_name, hash_including(data: hash_including(cuisine_type_select_target: "input")))
      render_inline(component)
    end

    it 'renders the hidden input field for cuisine type name' do
      expect(form).to receive(:hidden_field).with(:cuisine_type_name, hash_including(data: hash_including(cuisine_type_select_target: "hiddenInput")))
      render_inline(component)
    end

    describe '#cuisine_types_json' do
      it 'returns the correct JSON representation of cuisine types' do
        expected_json = [
          {
            id: 1,
            name: "Italian",
            value: "italian"
          },
          {
            id: 2,
            name: "Japanese",
            value: "japanese"
          },
          {
            id: 3,
            name: "Mexican",
            value: "mexican"
          }
        ].to_json

        expect(component.cuisine_types_json).to eq(expected_json)
      end
    end

    context 'when a cuisine type is already selected' do
      let(:selected_cuisine_type) { double('CuisineType', id: 1, name: 'italian', translated_name: 'Italian') }
      let(:restaurant) { double('Restaurant', cuisine_type: selected_cuisine_type) }

      it 'pre-fills the input with the translated cuisine type name' do
        expect(form).to receive(:text_field).with(:cuisine_type_name, hash_including(value: "Italian"))
        render_inline(component)
      end

      it 'sets the hidden input value to the original cuisine type name' do
        expect(form).to receive(:hidden_field).with(:cuisine_type_name, hash_including(value: "italian"))
        render_inline(component)
      end
    end
  end
end
