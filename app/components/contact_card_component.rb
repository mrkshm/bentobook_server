class ContactCardComponent < ApplicationComponent
  include ActionView::Helpers::TagHelper

  def initialize(contact:, interactive: false, visit: nil)
    @contact = contact
    @interactive = interactive
    @visit = visit
  end

  def render_card_content
    content
  end

  private

  attr_reader :contact, :interactive, :visit
end
