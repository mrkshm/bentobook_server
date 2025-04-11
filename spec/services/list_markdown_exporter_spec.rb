require 'rails_helper'

RSpec.describe ListMarkdownExporter do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:list) { create(:list, :with_restaurants, organization: organization, creator: user) }

  before do
    create(:membership, user: user, organization: organization)
  end

  describe '#generate' do
    it 'generates markdown content' do
      exporter = described_class.new(list)
      content = exporter.generate

      expect(content).to include(list.name)
      expect(content).to include('# ')  # Should have markdown headers
      list.restaurants.each do |restaurant|
        expect(content).to include(restaurant.name)
      end
    end
  end
end
