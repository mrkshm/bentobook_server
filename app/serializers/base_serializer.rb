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

    pagination = if pagy
      items = pagy.vars[:items].to_i
      total = pagy.count
      total_pages = total.zero? ? 1 : (total.to_f / items).ceil
      {
        current_page: pagy.page,
        per_page: items.to_s,
        total_pages: total_pages,
        total_count: total
      }
    else
      {}
    end

    {
      status: "success",
      data: serialized_resources,
      meta: {
        timestamp: Time.current.iso8601,
        pagination: pagination
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

  def self.format_error(error)
    case error
    when String
      { detail: error }
    when ActiveModel::Error
      {
        source: { pointer: "/data/attributes/#{error.attribute}" },
        detail: error.message
      }
    else
      { detail: error.to_s }
    end
  end
end
