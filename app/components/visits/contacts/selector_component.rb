module Visits
  module Contacts
    class SelectorComponent < ViewComponent::Base
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include HeroiconHelper
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
        @frequent_contacts = Contact.frequently_used_with(
          @visit.user,
          @visit,
          limit: 5
        )
      end

      private

      attr_reader :visit

      def frame_id
        dom_id(@visit, :contacts)
      end
    end
  end
end
