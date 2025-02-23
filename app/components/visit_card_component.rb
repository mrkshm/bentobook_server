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

    content_tag :div, class: "flex flex-wrap gap-2" do
      @visit.contacts.map do |contact|
        link_to(contact_path(id: contact.id), class: "group flex flex-col items-center") do
          content_tag :div, class: "relative" do
            render(AvatarComponent.new(
              image: contact.avatar,
              text: contact.name,
              size: :sm
            ))
          end
        end
      end.join.html_safe
    end
  end
end
