class ContactSerializer
  include Alba::Resource

  attributes :id, :name, :email, :city, :country, :phone, :notes, :created_at, :updated_at, :avatar_url

  attribute :avatar_url do |contact|
    Rails.application.routes.url_helpers.url_for(contact.avatar) if contact.avatar.attached?
  end
end
