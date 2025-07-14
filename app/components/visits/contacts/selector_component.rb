module Visits
  module Contacts
    class SelectorComponent < ApplicationComponent
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
        @frequent_contacts = Contact.frequently_used_with(
          @visit.organization,
          @visit,
          limit: 5
        )
      end

      def frequent_contacts?
        @frequent_contacts.any?
      end

      private

      attr_reader :visit, :frequent_contacts

      def frame_id
        dom_id(@visit, :contacts)
      end
    end
  end
end
