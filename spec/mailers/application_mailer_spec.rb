require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'inherits from ActionMailer::Base' do
    expect(described_class.superclass).to eq(ActionMailer::Base)
  end

  it 'sets the correct default from address' do
    expect(described_class.default[:from]).to eq('noreply@bentobook.app')
  end

  it 'uses the correct layout' do
    expect(described_class._layout).to eq('mailer')
  end
end
