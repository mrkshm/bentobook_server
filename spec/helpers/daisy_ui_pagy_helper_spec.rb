require 'rails_helper'

RSpec.describe DaisyUiPagyHelper, type: :helper do
  let(:pagy) { double('Pagy') }
  let(:pagy_id) { 'test_id' }
  let(:link_extra) { 'data-turbo-frame="_top"' }

  before do
    allow(helper).to receive(:pagy_url_for).and_return('#')
  end

  describe '#pagy_daisy_ui_nav' do
    it 'renders the pagination container with correct id' do
      allow(pagy).to receive_messages(prev: nil, next: nil, series: [])
      result = helper.pagy_daisy_ui_nav(pagy, pagy_id: pagy_id)
      expect(result).to include('id="test_id"')
      expect(result).to include('class="join"')
    end

    it 'renders disabled previous button when on first page' do
      allow(pagy).to receive_messages(prev: nil, next: 2, series: [1])
      result = helper.pagy_daisy_ui_nav(pagy)
      expect(result).to include('<button class="join-item btn btn-disabled">«</button>')
    end

    it 'renders active previous button when not on first page' do
      allow(pagy).to receive_messages(prev: 1, next: 3, series: [2])
      result = helper.pagy_daisy_ui_nav(pagy, link_extra: link_extra)
      expect(result).to include('<a class="join-item btn" href="#" aria-label="previous" data-turbo-frame="_top">«</a>')
    end

    it 'renders page numbers correctly' do
      allow(pagy).to receive_messages(prev: 1, next: 3, series: [1, 2, 3])
      result = helper.pagy_daisy_ui_nav(pagy)
      expect(result).to include('class="join-item btn" href="#"')
      expect(result).to include('>1<')
      expect(result).to include('>2<')
      expect(result).to include('>3<')
    end

    it 'renders the current page as active' do
      allow(pagy).to receive_messages(prev: 1, next: 3, series: [1, '2', 3], label_for: '2')
      result = helper.pagy_daisy_ui_nav(pagy)
      expect(result).to include('<button class="join-item btn btn-active">2</button>')
    end

    it 'renders gap correctly' do
      allow(pagy).to receive_messages(prev: 1, next: 10, series: [1, 2, :gap, 9, 10])
      result = helper.pagy_daisy_ui_nav(pagy)
      expect(result).to include('<button class="join-item btn btn-disabled">…</button>')
    end

    it 'renders disabled next button when on last page' do
      allow(pagy).to receive_messages(prev: 9, next: nil, series: [10])
      result = helper.pagy_daisy_ui_nav(pagy)
      expect(result).to include('<button class="join-item btn btn-disabled">»</button>')
    end

    it 'renders active next button when not on last page' do
      allow(pagy).to receive_messages(prev: 1, next: 3, series: [2])
      result = helper.pagy_daisy_ui_nav(pagy, link_extra: link_extra)
      expect(result).to include('<a class="join-item btn" href="#" aria-label="next" data-turbo-frame="_top">»</a>')
    end

    it 'raises an error for unexpected series item' do
      allow(pagy).to receive_messages(prev: 1, next: 3, series: [:unexpected])
      expect {
        helper.pagy_daisy_ui_nav(pagy)
      }.to raise_error(StandardError, /expected item types in series to be Integer, String or :gap/)
    end
  end
end
