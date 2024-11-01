class CuisineType < ApplicationRecord
    has_many :restaurants

    validates :name, presence: true, uniqueness: {case_sensitive: false}

    # Use translated names for all alphabetical sorting
    scope :alphabetical, -> { all.sort_by { |ct| ct.translated_name.downcase } }

    def translated_name
        I18n.t("cuisine_types.#{name}", default: name)
    end
end
