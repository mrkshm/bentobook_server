class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates :imageable, presence: true
end
