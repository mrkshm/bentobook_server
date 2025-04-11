module Lists
  class SharedComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(organization:, current_user:)
      @organization = organization
      @current_user = current_user

      # Get pending shared lists
      @pending_lists = organization.shared_lists
                          .pending
                          .includes(:source_organization)

      # Get accepted shared lists
      @accepted_lists = organization.shared_lists
                           .accepted
                           .includes(:source_organization)
    end

    private

    attr_reader :organization, :current_user, :pending_lists, :accepted_lists
  end
end
