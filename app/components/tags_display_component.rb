class TagsDisplayComponent < ViewComponent::Base
  include ActionView::RecordIdentifier
  include HeroiconHelper
  include Turbo::FramesHelper

  def initialize(record:, container_classes: nil)
    @record = record
    @container_classes = container_classes
  end

  def frame_id
    dom_id(@record, :tags)
  end

  def has_tags?
    @record.tags.any?
  end

  def edit_path
    case @record
    when Restaurant
      edit_tags_restaurant_path(id: @record.id, locale: nil)
    when Contact
      # Implement when needed
      contact_path(id: @record.id, locale: nil)
    when Visit
      # Implement when needed
      visit_path(id: @record.id, locale: nil)
    end
  end

  def show_path
    case @record
    when Restaurant
      restaurant_path(id: @record.id, locale: nil)
    when Contact
      contact_path(id: @record.id, locale: nil)
    when Visit
      visit_path(id: @record.id, locale: nil)
    end
  end
end
