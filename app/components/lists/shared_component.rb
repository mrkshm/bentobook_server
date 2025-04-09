module Lists
  class SharedComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(organization:, current_user:)
      @organization = organization
      @current_user = current_user
      @pending_lists = organization.shared_lists
                          .pending
                          .includes(
                            :owner,
                            owner: { profile: { avatar_attachment: :blob } }
                          )
      @accepted_lists = organization.shared_lists
                           .accepted
                           .includes(
                             :owner,
                             owner: { profile: { avatar_attachment: :blob } }
                           )
    end

    private

    attr_reader :organization, :current_user, :pending_lists, :accepted_lists
  end
end
