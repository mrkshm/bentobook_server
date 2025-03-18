module Visits
  class ContactsComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers
    include HeroiconHelper

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
