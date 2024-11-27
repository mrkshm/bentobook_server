class BaseSerializer
  include Alba::Resource

  def self.render_success(resource, meta: {})
    serializer = new(resource)
    serialized = serializer.serialize
    parsed = JSON.parse(serialized)

    {
      status: "success",
      data: {
        id: resource.id.to_s,
        type: resource.class.name.underscore,
        attributes: parsed
      },
      meta: {
        timestamp: Time.current.iso8601
      }.merge(meta)
    }
  end

  def self.render_collection(resources, meta: {}, pagy: nil)
    serializer = new
    serialized_resources = resources.map { |resource|
      serialized = serializer.serialize(resource)
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
        pagination: pagy_metadata(pagy)
      }.merge(meta)
    }
  end

  def self.render_error(errors, meta: {})
    {
      status: "error",
      errors: Array(errors).map { |error| format_error(error) },
      meta: {
        timestamp: Time.current.iso8601
      }.merge(meta)
    }
  end

  private

  def self.pagy_metadata(pagy)
    return {} unless pagy

    {
      current_page: pagy.page,
      total_pages: pagy.pages,
      total_count: pagy.count,
      per_page: pagy.items
    }
  end

  def self.format_error(error)
    case error
    when Hash
      error # Already formatted error hash
    when ActiveModel::Error
      {
        code: "validation_error",
        detail: error.message,
        source: { pointer: "/data/attributes/#{error.attribute}" }
      }
    when String
      { code: "general_error", detail: error }
    else
      { code: "general_error", detail: error.to_s }
    end
  end
end
