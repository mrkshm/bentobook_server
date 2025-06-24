# == Schema Information
#
# Table name: shares
#
#  id                     :bigint           not null, primary key
#  permission             :integer          default("view")
#  reshareable            :boolean          default(TRUE), not null
#  shareable_type         :string           not null
#  status                 :integer          default("pending")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  creator_id             :bigint           not null
#  shareable_id           :bigint           not null
#  source_organization_id :bigint           not null
#  target_organization_id :bigint           not null
#
# Indexes
#
#  index_shares_on_creator_id                   (creator_id)
#  index_shares_on_organizations_and_shareable  (source_organization_id,target_organization_id,shareable_type,shareable_id)
#  index_shares_on_shareable                    (shareable_type,shareable_id)
#  index_shares_on_source_organization_id       (source_organization_id)
#  index_shares_on_target_organization_id       (target_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (source_organization_id => organizations.id)
#  fk_rails_...  (target_organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe ShareSerializer do
  let(:creator) { create(:user) }
  let(:source_organization) { creator.organizations.first }
  let(:target_organization) { create(:organization) }
  let(:target_user) { create(:user) }
  let(:list) { create(:list, organization: source_organization, creator: creator) }
  let(:share) do
    create(:share,
      creator: creator,
      source_organization: source_organization,
      target_organization: target_organization,
      shareable: list,
      permission: :view,
      status: :pending,
      reshareable: true
    )
  end

  before do
    # Create membership to associate target user with target organization
    create(:membership, user: target_user, organization: target_organization)
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
        'source_organization',
        'target_organization',
        'shareable'
      )
    end

    it 'includes correct creator information' do
      creator_data = rendered_json[:data][:attributes]['creator']
      expect(creator_data).to include(
        'id' => creator.id,
        'name' => creator.display_name,
        'email' => creator.email
      )
    end

    it 'includes correct source organization information' do
      source_org_data = rendered_json[:data][:attributes]['source_organization']
      expect(source_org_data).to include(
        'id' => source_organization.id
      )
    end

    it 'includes correct target organization information' do
      target_org_data = rendered_json[:data][:attributes]['target_organization']
      expect(target_org_data).to include(
        'id' => target_organization.id
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
    let(:other_source_organization) { create(:organization) }
    let(:other_target_organization) { create(:organization) }
    let!(:other_share) do
      # Create memberships for creator in the other source organization
      create(:membership, user: creator, organization: other_source_organization)

      # Create a list in the other source organization
      other_list = create(:list, organization: other_source_organization, creator: creator)

      # Share with the other target organization
      create(:share,
             creator: creator,
             source_organization: other_source_organization,
             target_organization: other_target_organization,
             shareable: other_list)
    end
    let(:shares) { [ share, other_share ] }

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
          'source_organization',
          'target_organization',
          'shareable'
        )
      end
    end
  end
end
