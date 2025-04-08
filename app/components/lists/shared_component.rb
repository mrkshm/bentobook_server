module Lists
  class SharedComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(user:)
      @user = user
      @pending_lists = user.shared_lists
                          .pending
                          .includes(
                            :owner,
                            owner: { profile: { avatar_attachment: :blob } }
                          )
      @accepted_lists = user.shared_lists
                           .accepted
                           .includes(
                             :owner,
                             owner: { profile: { avatar_attachment: :blob } }
                           )
    end

    def before_render
      @current_user = @user
    end

    private

    attr_reader :user, :pending_lists, :accepted_lists
  end
end
