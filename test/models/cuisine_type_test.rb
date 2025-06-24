# == Schema Information
#
# Table name: cuisine_types
#
#  id            :bigint           not null, primary key
#  display_order :integer          default(0)
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :bigint
#
# Indexes
#
#  index_cuisine_types_on_category_id    (category_id)
#  index_cuisine_types_on_display_order  (display_order)
#  index_cuisine_types_on_name           (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
require "test_helper"

class CuisineTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
