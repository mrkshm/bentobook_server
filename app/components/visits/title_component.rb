module Visits
  class TitleComponent < ApplicationComponent
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:, primary: true)
      @visit = visit
      @primary = primary
    end

    private

    attr_reader :visit, :primary

    def frame_id
      dom_id(visit, :title)
    end

    def link_classes
      if primary
        "block text-2xl font-medium text-surface-900 hover:text-primary-600 transition-colors"
      else
        "block text-surface-500 hover:text-primary-600 transition-colors"
      end
    end
  end
end
