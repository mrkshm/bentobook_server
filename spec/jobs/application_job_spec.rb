require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'is an ActiveJob::Base class' do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end

  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

end

