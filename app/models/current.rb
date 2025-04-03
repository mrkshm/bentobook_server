class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :organization

  # Resets organization when user changes
  resets { self.organization = nil }

  class << self
    # Returns the current organization context, raising an error if none is set
    def organization!
      organization or raise "No organization context set"
    end

    # Sets the current organization, with optional validation
    def organization=(org)
      raise "Organization must belong to current user" if org && user && !user.organizations.include?(org)
      super
    end
  end
end
