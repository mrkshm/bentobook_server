module Visits
  module Contacts
    class SelectorComponent < ViewComponent::Base
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include HeroiconHelper

      def initialize(visit:)
        @visit = visit
        @frequent_contacts = Contact.frequently_used_with(
          @visit.user,
          @visit,
          limit: 5
        )
      end

      private

      def frame_id
        dom_id(@visit, :contacts)
      end
    end
  end
end
