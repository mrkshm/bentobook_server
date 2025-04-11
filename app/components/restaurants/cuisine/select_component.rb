# frozen_string_literal: true

module Restaurants
  module Cuisine
    class SelectComponent < ApplicationComponent
      def initialize(form:, cuisine_types: nil, readonly: false)
        @form = form
        @cuisine_types = cuisine_types || CuisineType.includes(:category).all
        @readonly = readonly
      end

      def cuisine_types_json
        cuisine_types_data = @cuisine_types.map do |ct|
          {
            id: ct.id,
            name: ct.translated_name,
            value: ct.name,
            category_id: ct.category_id,
            category_name: ct.category&.translated_name || "Other",
            display_order: ct.display_order
          }
        end

        # Group by category
        grouped_data = cuisine_types_data.group_by { |ct| ct[:category_name] }
        
        # Convert to array of categories with cuisine types
        categories_data = grouped_data.map do |category_name, cuisine_types|
          {
            name: category_name,
            cuisine_types: cuisine_types.sort_by { |ct| ct[:display_order] }
          }
        end

        # Sort categories by their first cuisine type's category display order
        categories_data.sort_by! do |category| 
          first_cuisine = category[:cuisine_types].first
          first_cuisine ? first_cuisine[:category_id] || 999 : 999
        end

        categories_data.to_json
      end

      def categorized_cuisine_types
        CuisineType.includes(:category).by_category.group_by(&:category)
      end

      private

      attr_reader :form, :cuisine_types, :readonly
      alias_method :readonly?, :readonly
    end
  end
end
