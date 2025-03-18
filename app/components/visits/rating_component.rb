module Visits
  class RatingComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(visit:)
      @visit = visit
    end

    private

    def frame_id
      dom_id(@visit, :rating)
    end
  end
end
