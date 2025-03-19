module Visits
  module Title
    class FormComponent < ApplicationComponent
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
      end

      private

      def frame_id
        dom_id(@visit, :title)
      end
    end
  end
end
