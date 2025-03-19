class NotesComponent < ApplicationComponent
  include ActionView::RecordIdentifier
  include Turbo::FramesHelper  # Add this line to include turbo_frame_tag

  def initialize(record:, notes_field: :notes, container_classes: nil, notes_edit: false)
    @record = record
    @notes_field = notes_field
    @container_classes = container_classes
    @notes_edit = notes_edit
  end

  def frame_id
    dom_id(@record, :notes)
  end

  def notes_content
    @record.public_send(@notes_field)
  end

  def has_notes?
    notes_content.present?
  end

  def update_url
    case @record
    when Restaurant
      update_notes_restaurant_path(id: @record.id, locale: current_locale)
    when Contact
      contact_path(id: @record.id, locale: current_locale)
    when Visit
      visit_path(id: @record.id, locale: current_locale)
    end
  end

  def edit_path
    case @record
    when Restaurant
      restaurant_path(id: @record.id, locale: current_locale, notes_edit: true)
    when Contact
      contact_path(id: @record.id, locale: current_locale, notes_edit: true)
    when Visit
      visit_path(id: @record.id, locale: current_locale, notes_edit: true)
    end
  end

  def show_path
    case @record
    when Restaurant
      restaurant_path(id: @record.id, locale: current_locale)
    when Contact
      contact_path(id: @record.id, locale: current_locale)
    when Visit
      visit_path(id: @record.id, locale: current_locale)
    end
  end

  def editing?
    @notes_edit
  end
end
