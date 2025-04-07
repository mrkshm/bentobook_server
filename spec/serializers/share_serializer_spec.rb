require 'rails_helper'

RSpec.describe ShareSerializer do
  let(:creator) { create(:user, :with_profile) }
  let(:recipient) { create(:user, :with_profile) }
  let(:organization) { create(:organization) }
  let(:list) { create(:list, organization: organization, creator: creator) }
  let(:share) do
    create(:share,
      creator: creator,
      recipient: recipient,
      shareable: list,
      permission: :view,
      status: :pending,
      reshareable: true
    )
  end

  before do
    # Create membership to associate creator with organization
    create(:membership, user: creator, organization: organization)
  end

  describe '.render_success' do
    subject(:rendered_json) { ShareSerializer.render_success(share) }

    it 'follows the JSON API format' do
      expect(rendered_json).to have_key(:data)
      expect(rendered_json[:data]).to have_key(:attributes)
    end

    it 'includes the correct attributes' do
      expect(rendered_json[:data][:attributes]).to include(
        'status',
        'permission',
        'reshareable',
        'created_at',
        'updated_at',
        'creator',
        'recipient',
        'shareable'
      )
    end

    it 'includes correct creator information' do
      creator_data = rendered_json[:data][:attributes]['creator']
      expect(creator_data).to include(
        'id' => creator.id,
        'name' => creator.profile.display_name,
        'email' => creator.email
      )
    end

    it 'includes correct recipient information' do
      recipient_data = rendered_json[:data][:attributes]['recipient']
      expect(recipient_data).to include(
        'id' => recipient.id,
        'name' => recipient.profile.display_name,
        'email' => recipient.email
      )
    end

    it 'includes correct shareable information for a list' do
      shareable_data = rendered_json[:data][:attributes]['shareable']
      expect(shareable_data).to include(
        'id' => list.id,
        'type' => 'List',
        'name' => list.name,
        'description' => list.description,
        'restaurant_count' => list.restaurants.count
      )
    end

    it 'includes correct status and permission values' do
      attributes = rendered_json[:data][:attributes]
      expect(attributes['status']).to eq('pending')
      expect(attributes['permission']).to eq('view')
      expect(attributes['reshareable']).to be true
    end
  end

  describe '.render_collection' do
    let(:other_organization) { create(:organization) }
    let!(:other_share) do 
      other_list = create(:list, organization: other_organization, creator: creator)
      create(:share, creator: creator, recipient: recipient, shareable: other_list)
    end
    let(:shares) { [ share, other_share ] }

    before do
      # Create membership for creator in other organization
      create(:membership, user: creator, organization: other_organization)
    end

    subject(:rendered_json) { ShareSerializer.render_collection(shares) }

    it 'renders a collection of shares' do
      expect(rendered_json[:data].length).to eq(2)
      expect(rendered_json[:data].first[:type]).to eq('share')
      expect(rendered_json[:data].second[:type]).to eq('share')
    end

    it 'includes all necessary attributes for each share' do
      rendered_json[:data].each do |share_data|
        expect(share_data[:attributes]).to include(
          'status',
          'permission',
          'reshareable',
          'created_at',
          'updated_at',
          'creator',
          'recipient',
          'shareable'
        )
      end
    end
  end
end
