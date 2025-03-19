module Visits
  module Date
    class FormComponent < ApplicationComponent
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
      end

      private

      def frame_id
        dom_id(@visit, :date)
      end
    end
  end
end
