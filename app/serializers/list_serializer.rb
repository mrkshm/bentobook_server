# == Schema Information
#
# Table name: lists
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string           not null
#  position        :integer
#  premium         :boolean          default(FALSE)
#  visibility      :integer          default("personal")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :bigint           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_lists_on_creator_id       (creator_id)
#  index_lists_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class ListSerializer < BaseSerializer
  attributes :name, :description, :visibility, :premium, :position, :created_at, :updated_at

  attribute :restaurant_count do
    object.restaurants.count
  end

  attribute :restaurants, if: :include_restaurants? do
    object.restaurants.map do |r|
      {
        id: r.id,
        name: r.name,
        address: r.address,
        postal_code: r.postal_code,
        city: r.city,
        state: r.state,
        country: r.country,
        rating: r.rating,
        price_level: r.price_level
      }
    end
  end

  attribute :shared_with do
    object.shares.accepted.map do |share|
      {
        organization_id: share.target_organization_id,
        permission: share.permission
      }
    end
  end

  private

  def include_restaurants?
    @options[:include_restaurants]
  end
end
