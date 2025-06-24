# == Schema Information
#
# Table name: images
#
#  id             :bigint           not null, primary key
#  description    :text
#  imageable_type :string           not null
#  is_cover       :boolean
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  imageable_id   :bigint           not null
#
# Indexes
#
#  index_images_on_imageable  (imageable_type,imageable_id)
#
require "test_helper"

class ImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
