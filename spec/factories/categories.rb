# == Schema Information
#
# Table name: categories
#
#  id            :bigint           not null, primary key
#  display_order :integer          default(0)
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_categories_on_display_order  (display_order)
#  index_categories_on_name           (name) UNIQUE
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:display_order)
  end
end
