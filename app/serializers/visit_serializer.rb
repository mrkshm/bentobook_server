# == Schema Information
#
# Table name: visits
#
#  id                  :bigint           not null, primary key
#  date                :date
#  notes               :text
#  price_paid_cents    :integer
#  price_paid_currency :string
#  rating              :integer
#  time_of_day         :time             not null
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :bigint           not null
#  restaurant_id       :bigint           not null
#
# Indexes
#
#  index_visits_on_organization_id  (organization_id)
#  index_visits_on_restaurant_id    (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (restaurant_id => restaurants.id)
#
class VisitSerializer < BaseSerializer
  include Rails.application.routes.url_helpers

  attributes :date,
             :title,
             :notes,
             :rating,
             :created_at,
             :updated_at

  attribute :restaurant do |visit|
    begin
      lat = visit.restaurant.latitude
      lon = visit.restaurant.longitude

      {
        id: visit.restaurant.id,
        name: visit.restaurant.name,
        cuisine_type: visit.restaurant.cuisine_type&.name,
        location: {
          address: visit.restaurant.address,
          latitude: lat.present? ? lat.to_f : nil,
          longitude: lon.present? ? lon.to_f : nil
        }
      }
    rescue StandardError => _e
      # Return minimal restaurant data on error
      {
        id: visit.restaurant.id,
        name: visit.restaurant.name,
        location: { address: nil, latitude: nil, longitude: nil }
      }
    end
  end

  attribute :contacts do |visit|
    visit.contacts.map do |contact|
      avatar_urls = {}

      if contact.avatar_thumbnail.attached?
        begin
          avatar_urls[:thumbnail] = rails_blob_url(contact.avatar_thumbnail)
        rescue StandardError => _e
          # Ignore errors with avatar URLs
        end
      end

      if contact.avatar_medium.attached?
        begin
          avatar_urls[:medium] = rails_blob_url(contact.avatar_medium)
        rescue StandardError => _e
          # Ignore errors with avatar URLs
        end
      end

      {
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        notes: contact.notes,
        avatar_urls: avatar_urls.present? ? avatar_urls : nil
      }
    end
  end

  attribute :price_paid do |visit|
    if visit.price_paid_cents.present? && visit.price_paid_currency.present?
      begin
        amount = visit.price_paid_cents.to_s.to_f / 100.0
        {
          amount: sprintf("%.2f", amount),
          currency: visit.price_paid_currency.to_s
        }
      rescue StandardError => _e
        nil
      end
    end
  end

  attribute :images do |visit|
    visit.images.map do |image|
      next unless image.file.attached?

      begin
        urls = {
          thumbnail: rails_blob_url(image.file.variant(
            resize_to_fill: [ 100, 100 ],
            format: :webp,
            saver: { quality: 80 }
          )),
          small: rails_blob_url(image.file.variant(
            resize_to_limit: [ 300, 200 ],
            format: :webp,
            saver: { quality: 80 }
          )),
          medium: rails_blob_url(image.file.variant(
            resize_to_limit: [ 600, 400 ],
            format: :webp,
            saver: { quality: 80 }
          )),
          large: rails_blob_url(image.file.variant(
            resize_to_limit: [ 1200, 800 ],
            format: :webp,
            saver: { quality: 80 }
          )),
          original: rails_blob_url(image.file)
        }
        {
          id: image.id,
          urls: urls
        }
      rescue StandardError => _e
        {
          id: image.id,
          urls: {}
        }
      end
    end.compact
  end
end
