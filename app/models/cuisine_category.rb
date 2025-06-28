class CuisineCategory < ApplicationRecord
  has_many :cuisine_types, dependent: :destroy

  scope :ordered, -> { order(display_order: :asc, name: :asc) }
end
