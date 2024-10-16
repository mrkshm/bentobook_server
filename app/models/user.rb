class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable

  # Skip confirmation emails in development
  def confirmation_required?
    Rails.env.production?
  end

  has_many :restaurants
  has_many :google_restaurants, through: :restaurants
  has_many :memberships
  has_many :organizations, through: :memberships
  has_many :contacts
  has_many :visits
  has_many :images, as: :imageable, dependent: :destroy
  has_one :profile, dependent: :destroy
  after_create :ensure_profile

  def all_tags
    Restaurant.where(user_id: id).tag_counts_on(:tags)
  end

  # Disable account locking in development
  def lock_access!
    Rails.env.production? ? super : nil
  end

  private 
  
  def ensure_profile
    create_profile if profile.nil?
  end
end
