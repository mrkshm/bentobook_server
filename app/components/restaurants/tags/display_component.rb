module Restaurants
  module Tags
    class DisplayComponent < ViewComponent::Base
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
        edit_restaurant_tags_path(restaurant_id: @record.id, locale: nil)
      end
    end
  end
end
