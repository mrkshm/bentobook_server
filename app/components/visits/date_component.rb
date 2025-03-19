module Visits
  class DateComponent < ApplicationComponent
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:, primary: false)
      @visit = visit
      @primary = primary
    end

    private

    attr_reader :visit, :primary

    def frame_id
      dom_id(visit, :date)
    end

    def link_classes
      if primary
        "inline-flex items-center text-2xl font-semibold text-surface-900 hover:text-primary-600"
      else
        "inline-flex items-center text-surface-700 hover:text-primary-600"
      end
    end
  end
end
