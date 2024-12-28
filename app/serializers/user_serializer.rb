class UserSerializer < BaseSerializer
  attributes :id,
             :email,
             :created_at

  has_one :profile, serializer: ProfileSerializer
end
