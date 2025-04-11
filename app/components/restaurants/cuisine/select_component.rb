# frozen_string_literal: true

module Restaurants
  module Cuisine
    class SelectComponent < ApplicationComponent
      def initialize(form:, cuisine_types:, readonly: false)
        @form = form
        @cuisine_types = cuisine_types
        @readonly = readonly
      end

      def cuisine_types_json
        @cuisine_types.map do |ct|
          {
            id: ct.id,
            name: ct.translated_name,
            value: ct.name
          }
        end.to_json
      end

      private

      attr_reader :form, :cuisine_types, :readonly
      alias_method :readonly?, :readonly
    end
  end
end
