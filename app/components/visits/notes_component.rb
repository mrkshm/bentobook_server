module Visits
  class NotesComponent < ApplicationComponent
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:)
      @visit = visit
    end

    private

    def frame_id
      dom_id(@visit, :notes)
    end

    def edit_action_text
      hotwire_native_app? ? "Tap to edit" : "Click to edit"
    end
  end
end
