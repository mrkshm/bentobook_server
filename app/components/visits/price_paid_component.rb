module Visits
  class PricePaidComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:)
      @visit = visit
    end

    private

    attr_reader :visit

    def frame_id
      dom_id(visit, :price_paid)
    end

    def link_classes
      "inline-flex items-center text-surface-700 hover:text-primary-600"
    end
  end
end
