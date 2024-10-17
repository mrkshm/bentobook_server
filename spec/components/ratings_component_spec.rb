require 'rails_helper'

RSpec.describe RatingsComponent, type: :component do
  describe 'readonly version' do
    it 'renders the correct number of filled stars' do
      (0..5).each do |rating|
        component = described_class.new(rating: rating, readonly: true)
        render_inline(component)
        expect(page).to have_css('.text-yellow-400', count: rating)
        expect(page).to have_css('.text-gray-300', count: 5 - rating)
      end
    end

    it 'does not render any buttons' do
      component = described_class.new(rating: 3, readonly: true)
      render_inline(component)
      expect(page).not_to have_css('button')
    end
  end

  describe 'editable version' do
    let(:form) do
      double('form').tap do |f|
        allow(f).to receive(:hidden_field).and_return('<input type="hidden">')
      end
    end

    it 'renders 5 star buttons' do
      component = described_class.new(rating: 3, form: form)
      render_inline(component)
      expect(page).to have_css('button', count: 5)
    end

    it 'renders a hidden input field' do
      component = described_class.new(rating: 3, form: form)
      expect(form).to receive(:hidden_field).with(:rating, hash_including(data: { "ratings-target": "input" }))
      render_inline(component)
    end

    it 'applies correct classes to buttons based on rating' do
      component = described_class.new(rating: 3, form: form)
      render_inline(component)
      expect(page).to have_css('button.text-yellow-400', count: 3)
      expect(page).to have_css('button.text-gray-300', count: 2)
    end

    it 'sets correct data attributes on buttons' do
      component = described_class.new(rating: 3, form: form)
      render_inline(component)
      expect(page).to have_css('button[data-action="click->ratings#setRating mouseover->ratings#hoverRating mouseout->ratings#resetRating"]', count: 5)
      expect(page).to have_css('button[data-ratings-target="star"]', count: 5)
      (1..5).each do |i|
        expect(page).to have_css("button[data-value=\"#{i}\"]")
      end
    end
  end

  describe 'edge cases' do
    it 'handles nil rating' do
      component = described_class.new(rating: nil, readonly: true)
      render_inline(component)
      expect(page).to have_css('.text-gray-300', count: 5)
    end

    it 'handles string rating' do
      component = described_class.new(rating: '3', readonly: true)
      render_inline(component)
      expect(page).to have_css('.text-yellow-400', count: 3)
      expect(page).to have_css('.text-gray-300', count: 2)
    end

    it 'handles rating greater than 5' do
      component = described_class.new(rating: 7, readonly: true)
      render_inline(component)
      expect(page).to have_css('.text-yellow-400', count: 5)
    end

    it 'handles negative rating' do
      component = described_class.new(rating: -2, readonly: true)
      render_inline(component)
      expect(page).to have_css('.text-gray-300', count: 5)
    end
  end
end