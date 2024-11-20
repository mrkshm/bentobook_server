class BaseSerializer
  include Alba::Resource

  def self.render_success(resource, meta: {})
    {
      status: "success",
      data: {
        id: resource.id.to_s,
        type: resource.class.name.underscore,
        attributes: JSON.parse(new(resource).serialize)
      },
      meta: {
        timestamp: Time.current.iso8601
      }.merge(meta)
    }
  end

  def self.render_collection(resources, meta: {}, pagy: nil)
    {
      status: "success",
      data: resources.map { |resource|
        {
          id: resource.id.to_s,
          type: resource.class.name.underscore,
          attributes: JSON.parse(new(resource).serialize)
        }
      },
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
      items_per_page: pagy.items,
      next_page: pagy.next,
      prev_page: pagy.prev
    }
  end

  def self.format_error(error)
    case error
    when ActiveModel::Error
      {
        code: "validation_error",
        detail: error.message,
        source: { pointer: "/data/attributes/#{error.attribute}" }
      }
    else
      {
        code: "general_error",
        detail: error.to_s
      }
    end
  end
end
