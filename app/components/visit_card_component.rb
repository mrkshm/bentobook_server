# frozen_string_literal: true

class VisitCardComponent < ViewComponent::Base
  def initialize(visit:, link_to_show: true)
    @visit = visit
    @link_to_show = link_to_show
  end

  private

  attr_reader :visit, :link_to_show

  def render_contacts
    return unless @visit.contacts.any?

    content_tag :div do
      @visit.contacts.map do |contact|
        link_to contact.name, contact_path(id: contact.id)
      end.join(", ").html_safe
    end
  end
end
