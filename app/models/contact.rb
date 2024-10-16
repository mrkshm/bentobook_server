class Contact < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar

  validates :name, presence: true, uniqueness: { scope: :user_id }

end
