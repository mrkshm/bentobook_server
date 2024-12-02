class BaseSerializer
  include Alba::Resource

  attr_reader :options

  def initialize(resource, options = {})
    @options = options
    super(resource)
  end

  def self.render_success(resource, meta: {}, **options)
    serializer = new(resource, options)
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

  def self.render_collection(resources, meta: {}, pagy: nil, **options)
    {
      status: "success",
      data: resources.map do |resource|
        serializer = new(resource, options)
        serialized = serializer.serialize
        parsed = JSON.parse(serialized)

        {
          id: resource.id.to_s,
          type: resource.class.name.underscore,
          attributes: parsed
        }
      end,
      meta: {
        timestamp: Time.current.iso8601,
        pagination: pagy
      }.merge(meta)
    }
  end

  def self.render_error(message, code = :unprocessable_entity, pointer = nil)
    {
      status: "error",
      errors: [ {
        code: code.to_s,
        detail: message,
        source: pointer ? { pointer: pointer } : nil
      }.compact ],
      meta: {
        timestamp: Time.current.iso8601
      }
    }
  end

  def self.render_validation_errors(resource)
    {
      status: "error",
      errors: resource.errors.map { |error|
        {
          code: "validation_error",
          detail: error.full_message,
          source: { pointer: "/data/attributes/#{error.attribute}" }
        }
      },
      meta: {
        timestamp: Time.current.iso8601
      }
    }
  end
end
