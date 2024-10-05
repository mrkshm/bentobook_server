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

  # Disable account locking in development
  def lock_access!
    super unless Rails.env.development?
  end
end
