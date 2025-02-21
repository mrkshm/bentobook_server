class NotesComponent < ViewComponent::Base
  include ActionView::RecordIdentifier
  include HeroiconHelper

  def initialize(record:, notes_field: :notes, container_classes: nil)
    @record = record
    @notes_field = notes_field
    @container_classes = container_classes
  end

  private

  def notes_content
    @record.public_send(@notes_field)
  end

  def has_notes?
    notes_content.present?
  end

  def update_url
    case @record
    when Restaurant
      restaurant_path(id: @record.id, locale: nil)
    when Contact
      contact_path(id: @record.id, locale: nil)
    when Visit
      visit_path(id: @record.id, locale: nil)
    end
  end

  def component_id
    dom_id(@record, :notes)
  end
end
