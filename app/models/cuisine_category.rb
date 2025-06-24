class CuisineCategory < ApplicationRecord
  has_many :cuisine_types, dependent: :destroy
end
