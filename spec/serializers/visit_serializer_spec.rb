require 'rails_helper'
require 'fileutils'

RSpec.describe VisitSerializer do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:contact) { create(:contact, user: user) }
  let(:visit) do
    create(:visit, 
      user: user, 
      restaurant: restaurant, 
      contacts: [contact],
      price_paid_cents: 1000,
      price_paid_currency: 'USD'
    )
  end

  describe '#serialize' do
    subject(:serialized_visit) { VisitSerializer.new(visit).serialize }

    it 'includes the correct keys' do
      parsed_json = JSON.parse(serialized_visit)
      expect(parsed_json.keys).to match_array(%w[id date title notes rating created_at updated_at price_paid restaurant contacts images])
    end

    it 'has the correct basic attributes' do
      parsed_json = JSON.parse(serialized_visit)
      expect(parsed_json['id']).to eq(visit.id)
      expect(parsed_json['date']).to eq(visit.date.to_s)
      expect(parsed_json['title']).to eq(visit.title)
      expect(parsed_json['notes']).to eq(visit.notes)
      expect(parsed_json['rating']).to eq(visit.rating)
      expect(Time.parse(parsed_json['created_at'])).to be_within(1.second).of(visit.created_at)
      expect(Time.parse(parsed_json['updated_at'])).to be_within(1.second).of(visit.updated_at)
    end

    it 'has the correct price_paid' do
      parsed_json = JSON.parse(serialized_visit)
      expect(parsed_json['price_paid']).to eq({
        'amount' => '10.00',
        'currency' => 'USD'
      })
    end

    it 'includes restaurant information' do
      parsed_json = JSON.parse(serialized_visit)
      expect(parsed_json['restaurant']).to be_present
    end

    it 'includes contacts information' do
      parsed_json = JSON.parse(serialized_visit)
      expect(parsed_json['contacts']).to be_an(Array)
      expect(parsed_json['contacts'].length).to eq(1)
    end
  end

  context 'when visit has images' do
    before do
      # Ensure the Visit model has_many_attached :images
      allow(Visit).to receive(:has_many_attached).with(:images)

      # Mock the image attachment
      image = double('image', id: 1, file: double('file'))
      allow(visit).to receive(:images).and_return([image])
      allow(Rails.application.routes.url_helpers).to receive(:url_for).with(image.file).and_return('http://example.com/image.jpg')
    end

    it 'includes image information' do
      serialized_visit = JSON.parse(VisitSerializer.new(visit).serialize)

      expect(serialized_visit['images']).to be_an(Array)
      expect(serialized_visit['images'].length).to eq(1)
      expect(serialized_visit['images'].first).to include(
        'id' => 1,
        'url' => 'http://example.com/image.jpg'
      )
    end
  end

  context 'when visit has no price' do
    let(:visit_without_price) { create(:visit, user: user, restaurant: restaurant, price_paid_cents: nil, price_paid_currency: nil) }

    it 'returns nil for price_paid' do
      parsed_json = JSON.parse(VisitSerializer.new(visit_without_price).serialize)
      expect(parsed_json['price_paid']).to be_nil
    end
  end
end
