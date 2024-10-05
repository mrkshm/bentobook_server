class VisitContact < ApplicationRecord
  belongs_to :visit
  belongs_to :contact
end
