class ContactSerializer < BaseSerializer
  attributes :name,
             :email,
             :city,
             :country,
             :phone,
             :notes,
             :created_at,
             :updated_at,
             :visits_count

  attribute :avatar_urls do |contact|
    if contact.avatar.attached?
      {
        original: Rails.application.routes.url_helpers.rails_blob_url(
          contact.avatar,
          host: Rails.application.config.action_mailer.default_url_options[:host]
        )
      }
    end
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
