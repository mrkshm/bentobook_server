# == Schema Information
#
# Table name: contacts
#
#  id              :bigint           not null, primary key
#  city            :string
#  country         :string
#  email           :string
#  name            :string
#  notes           :text
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_contacts_on_name_and_organization_id  (name,organization_id) UNIQUE
#  index_contacts_on_organization_id           (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "test_helper"

class ContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
