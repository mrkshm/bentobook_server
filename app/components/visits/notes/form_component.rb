module Visits
  module Notes
    class FormComponent < ViewComponent::Base
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
      end

      private

      attr_reader :visit

      def frame_id
        dom_id(visit, :notes)
      end
    end
  end
end
