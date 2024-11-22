class SessionSerializer < BaseSerializer
  attribute :token do |session|
    session.token
  end

  attribute :user do |session|
    {
      id: session.user.id,
      type: "user",
      attributes: {
        email: session.user.email
      }
    }
  end

  attributes :device_info, :client_name, :last_used_at
end
