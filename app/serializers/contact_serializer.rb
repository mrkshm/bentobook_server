class ContactSerializer < BaseSerializer
  include Rails.application.routes.url_helpers

  attributes :name,
             :email,
             :city,
             :country,
             :phone,
             :notes,
             :created_at,
             :updated_at,
             :visits_count

  attribute :visits do |contact|
    if contact.association(:visits).loaded?
      contact.visits.map do |visit|
        {
          id: visit.id,
          date: visit.date,
          title: visit.title,
          notes: visit.notes,
          rating: visit.rating,
          restaurant: {
            id: visit.restaurant.id,
            name: visit.restaurant.combined_name,
            cuisine_type: visit.restaurant.cuisine_type&.name,
            location: {
              address: visit.restaurant.combined_address,
              latitude: visit.restaurant.combined_latitude&.to_f,
              longitude: visit.restaurant.combined_longitude&.to_f
            }
          },
          images: visit.images.map do |image|
            next unless image.file.attached?
            {
              id: image.id,
              urls: {
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
                ))
              }
            }
          end.compact
        }
      end
    end
  end

  attribute :avatar_urls do |contact|
    urls = {}

    if contact.avatar_thumbnail.attached?
      urls[:thumbnail] = Rails.application.routes.url_helpers.rails_blob_url(
        contact.avatar_thumbnail,
        host: Rails.application.config.action_mailer.default_url_options[:host]
      )
    end

    if contact.avatar_medium.attached?
      urls[:medium] = Rails.application.routes.url_helpers.rails_blob_url(
        contact.avatar_medium,
        host: Rails.application.config.action_mailer.default_url_options[:host]
      )
    end

    urls.present? ? urls : nil
  end

  def self.render_collection(resources, meta: {}, pagy: nil)
    serialized_resources = resources.map { |resource|
      serializer = new(resource)
      serialized = serializer.serialize
      parsed = JSON.parse(serialized)

      {
        id: resource.id.to_s,
        type: resource.class.name.underscore,
        attributes: parsed
      }
    }

    {
      status: "success",
      data: serialized_resources,
      meta: {
        timestamp: Time.current.iso8601,
        pagination: pagy ? {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: Pagy::DEFAULT[:items]
        } : nil
      }.merge(meta)
    }
  end
end
