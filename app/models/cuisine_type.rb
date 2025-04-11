class CuisineType < ApplicationRecord
  belongs_to :category, optional: true
  has_many :restaurants

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  
  # Scopes
  scope :alphabetical, -> { all.sort_by { |ct| ct.translated_name.downcase } }
  scope :by_category, -> { includes(:category).order('categories.display_order', :display_order) }
  scope :in_category, ->(category_id) { where(category_id: category_id).order(:display_order) }
  
  def translated_name
    I18n.t("cuisine_types.#{name}", default: name)
  end
  
  # Helper method to get cuisine types grouped by category
  def self.grouped_by_category
    by_category.group_by(&:category)
  end
end
