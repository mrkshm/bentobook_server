# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  role            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_memberships_on_organization_id  (organization_id)
#  index_memberships_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
