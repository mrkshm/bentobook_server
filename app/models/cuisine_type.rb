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
class CuisineType < ApplicationRecord
  belongs_to :cuisine_category
  has_many :restaurants

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :alphabetical, -> { all.sort_by { |ct| ct.translated_name.downcase } }
  scope :by_category, -> { includes(:category).order("categories.display_order", :display_order) }
  scope :in_category, ->(category_id) { where(category_id: category_id).order(:display_order) }
  scope :ordered, -> { order(display_order: :asc, name: :asc) }

  def translated_name
    I18n.t("cuisine_types.#{name}", default: name)
  end

  # Helper method to get cuisine types grouped by category
  def self.grouped_by_category
    by_category.group_by(&:category)
  end
end
