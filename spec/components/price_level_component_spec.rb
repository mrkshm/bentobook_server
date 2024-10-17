require 'rails_helper'

RSpec.describe PriceLevelComponent, type: :component do
  let(:restaurant) { Restaurant.new(price_level: 2) }

  describe 'readonly version' do
    let(:component) { described_class.new(restaurant: restaurant) }

    it 'renders the price level display' do
      render_inline(component)
      expect(page).to have_css('span.font-bold.text-green-600', text: '$$')
    end

    it 'does not render a select element' do
      render_inline(component)
      expect(page).not_to have_css('select')
    end
  end

  describe 'editable version' do
    let(:form) do
      double('form').tap do |f|
        allow(f).to receive(:select)
      end
    end
    let(:component) { described_class.new(restaurant: restaurant, form: form) }

    it 'renders a select element' do
      expect(form).to receive(:select).with(
        :price_level,
        [['$', 1], ['$$', 2], ['$$$', 3], ['$$$$', 4]],
        { include_blank: "Select price level" },
        class: "select select-bordered w-full max-w-xs"
      )
      render_inline(component)
    end

    it 'does not render the readonly price level display' do
      render_inline(component)
      expect(page).not_to have_css('span.font-bold.text-green-600')
    end
  end

  describe 'price level options' do
    let(:component) { described_class.new(restaurant: restaurant) }

    it 'returns the correct price level options' do
      expect(component.send(:price_level_options)).to eq([
        ['$', 1],
        ['$$', 2],
        ['$$$', 3],
        ['$$$$', 4]
      ])
    end
  end

  describe 'with different price levels' do
    [
      [1, '$'],
      [2, '$$'],
      [3, '$$$'],
      [4, '$$$$'],
      [nil, '']
    ].each do |price_level, expected_display|
      context "when price level is #{price_level || 'nil'}" do
        let(:restaurant) { Restaurant.new(price_level: price_level) }
        let(:component) { described_class.new(restaurant: restaurant) }

        it "renders the correct price level display" do
          render_inline(component)
          expect(page).to have_css('span.font-bold.text-green-600', text: expected_display)
        end
      end
    end
  end
end

