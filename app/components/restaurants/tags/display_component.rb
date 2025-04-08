module Restaurants
  module Tags
    class DisplayComponent < ApplicationComponent
      include ActionView::RecordIdentifier
      include Turbo::FramesHelper
      include HeroiconHelper

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
        edit_restaurant_tags_path(restaurant_id: @record.id, locale: current_locale)
      end

      def current_locale
        I18n.locale
      end
    end
  end
end
