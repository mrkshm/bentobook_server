class UserSerializer
  include Alba::Resource

  attributes :id, :email, :created_at

  def self.render(resource)
    new(resource).serialize
  end
end
