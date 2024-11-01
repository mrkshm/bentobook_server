require 'rails_helper'

RSpec.describe CuisineTypeSelectComponent, type: :component do
  let(:cuisine_types) do
    [
      CuisineType.new(id: 1, name: 'Italian'),
      CuisineType.new(id: 2, name: 'Japanese'),
      CuisineType.new(id: 3, name: 'Mexican')
    ]
  end

  let(:restaurant) { Restaurant.new }
  let(:form) do
    double('form').tap do |f|
      allow(f).to receive(:label)
      allow(f).to receive(:text_field)
      allow(f).to receive(:hidden_field)
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

  it 'renders the hidden input field for cuisine type id' do
    expect(form).to receive(:hidden_field).with(:cuisine_type_id, hash_including(data: hash_including(cuisine_type_select_target: "hiddenInput")))
    render_inline(component)
  end

  it 'renders the results container' do
    render_inline(component)
    expect(page).to have_css('ul[data-cuisine-type-select-target="results"]')
  end

  describe '#cuisine_types_json' do
    it 'returns the correct JSON representation of cuisine types' do
      expected_json = [
        { id: 1, name: 'Italian', translated_name: 'Italian' },
        { id: 2, name: 'Japanese', translated_name: 'Japanese' },
        { id: 3, name: 'Mexican', translated_name: 'Mexican' }
      ].to_json

      expect(component.cuisine_types_json).to eq(expected_json)
    end
  end

  context 'when a cuisine type is already selected' do
    let(:selected_cuisine_type) { CuisineType.new(id: 1, name: 'Italian') }
    let(:restaurant) { Restaurant.new(cuisine_type: selected_cuisine_type) }

    it 'pre-fills the input with the selected cuisine type name' do
      expect(form).to receive(:text_field).with(:cuisine_type_name, hash_including(value: 'Italian'))
      render_inline(component)
    end

    it 'sets the hidden input value to the selected cuisine type id' do
      expect(form).to receive(:hidden_field).with(:cuisine_type_id, hash_including(value: 1))
      render_inline(component)
    end
  end
end
