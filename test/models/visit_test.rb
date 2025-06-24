# == Schema Information
#
# Table name: visits
#
#  id                  :bigint           not null, primary key
#  date                :date
#  notes               :text
#  price_paid_cents    :integer
#  price_paid_currency :string
#  rating              :integer
#  time_of_day         :time             not null
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :bigint           not null
#  restaurant_id       :bigint           not null
#
# Indexes
#
#  index_visits_on_organization_id  (organization_id)
#  index_visits_on_restaurant_id    (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (restaurant_id => restaurants.id)
#
require "test_helper"

class VisitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
