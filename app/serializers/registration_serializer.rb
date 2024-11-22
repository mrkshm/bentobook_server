class RegistrationSerializer < BaseSerializer
  attributes :email

  def self.render_success(user, token)
    super(user, meta: { token: token })
  end

  def self.render_error(errors)
    {
      status: "error",
      errors: errors.messages.flat_map { |attr, messages|
        messages.map { |msg|
          {
            code: "validation_error",
            detail: msg,
            source: { pointer: "/data/attributes/#{attr}" }
          }
        }
      },
      meta: {
        timestamp: Time.current.iso8601
      }
    }
  end

  def self.render_inactive_error
    {
      status: "error",
      errors: [ {
        code: "inactive_user",
        detail: "User is not activated",
        source: { pointer: "/data/attributes/status" }
      } ],
      meta: {
        timestamp: Time.current.iso8601
      }
    }
  end
end
