class Category < ApplicationRecord
  has_many :cuisine_types, dependent: :nullify
  
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :display_order, presence: true
  
  # Scopes
  scope :ordered, -> { order(:display_order) }
  
  def translated_name
    I18n.t("categories.#{name.parameterize.underscore}", default: name)
  end
  
  # Get all cuisine types in this category, ordered by display_order
  def ordered_cuisine_types
    cuisine_types.order(:display_order)
  end
end
