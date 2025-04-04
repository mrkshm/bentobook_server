require 'rails_helper'

RSpec.describe AllowlistedJwt, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end
end
