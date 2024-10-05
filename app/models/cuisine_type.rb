class CuisineType < ApplicationRecord
    has_many :restaurants

    validates :name, presence: true, uniqueness: {case_sensitive: false}

    scope :alphabetical, -> { order(:name) }
end
