module Visits
  class NotesComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(visit:)
      @visit = visit
    end

    private

    def frame_id
      dom_id(@visit, :notes)
    end
  end
end
