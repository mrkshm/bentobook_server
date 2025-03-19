module Visits
  class ContactsComponent < ApplicationComponent
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def initialize(visit:)
      @visit = visit
    end

    private

    attr_reader :visit

    def frame_id
      dom_id(visit, :contacts)
    end
  end
end
