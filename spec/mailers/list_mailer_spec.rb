require 'rails_helper'

RSpec.describe ListMailer, type: :mailer do
  describe '#export' do
    let(:user) { create(:user) }
    let(:list) { create(:list, :with_restaurants, owner: user) }
    let(:recipient) { 'test@example.com' }
    let(:options) { { include_stats: true } }
    
    subject(:mail) { described_class.export(list, recipient, options) }
    
    it 'renders the headers' do
      expect(mail.subject).to include(list.name)
      expect(mail.to).to eq([recipient])
    end
    
    it 'renders the body' do
      expect(mail.body.encoded).to include(list.name)
      expect(mail.body.encoded).to include(list.restaurants.first.name)
    end
  end
end
