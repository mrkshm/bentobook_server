class Organization < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
    has_many :restaurants
    has_many :visits
    has_many :contacts
end
