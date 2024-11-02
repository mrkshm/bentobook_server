# frozen_string_literal: true

class VisitCardComponent < ViewComponent::Base
  def initialize(visit:, link_to_show: true)
    @visit = visit
    @link_to_show = link_to_show
  end

  private

  attr_reader :visit, :link_to_show
end
