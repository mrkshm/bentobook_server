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
      lat = visit.restaurant.combined_latitude
      lon = visit.restaurant.combined_longitude

      {
        id: visit.restaurant.id,
        name: visit.restaurant.combined_name,
        cuisine_type: visit.restaurant.cuisine_type&.name,
        location: {
          address: visit.restaurant.combined_address,
          latitude: lat.present? ? lat.to_f : nil,
          longitude: lon.present? ? lon.to_f : nil
        }
      }
    rescue StandardError => e
      # Return minimal restaurant data on error
      {
        id: visit.restaurant.id,
        name: visit.restaurant.combined_name,
        location: { address: nil, latitude: nil, longitude: nil }
      }
    end
  end

  attribute :contacts do |visit|
    visit.contacts.map do |contact|
      {
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        notes: contact.notes
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
      rescue StandardError => e
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
      rescue StandardError => e
        {
          id: image.id,
          urls: {}
        }
      end
    end.compact
  end
end
