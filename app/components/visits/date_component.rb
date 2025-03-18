module Visits
  class DateComponent < ViewComponent::Base
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
