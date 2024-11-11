require 'rails_helper'

RSpec.describe ListMarkdownExporter do
  let(:user) { create(:user) }
  let(:list) { create(:list, :with_restaurants, owner: user) }
  
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
