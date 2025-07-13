module Visits
  class RatingComponent < ApplicationComponent
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:, readonly: false)
      @visit = visit
      @readonly = readonly
    end

    private

    def frame_id
      dom_id(@visit, :rating)
    end
  end
end
