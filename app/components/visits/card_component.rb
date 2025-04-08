# frozen_string_literal: true

module Visits
  class CardComponent < ApplicationComponent
    def initialize(visit:, link_to_show: true)
      @visit = visit
      @link_to_show = link_to_show
    end

    private

    attr_reader :visit, :link_to_show

    def has_title?
      visit.title && !visit.title.empty?
    end

    def has_notes?
      visit.notes && !visit.notes.empty?
    end

    def has_contacts?
      visit.contacts && visit.contacts.any?
    end

    def formatted_date
      visit.date.strftime("%B %d, %Y")
    end
  end
end
