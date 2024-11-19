# app/controllers/concerns/api/v1/restaurant_sorting_and_filtering.rb
module Api
    module V1
      module RestaurantSortingAndFiltering
        extend ActiveSupport::Concern
  
        ALLOWED_ORDER_FIELDS = %w[name created_at updated_at rating price_range]
        DEFAULT_ORDER = { field: 'created_at', direction: 'desc' }.freeze
  
        included do
          unless const_defined?(:ALLOWED_ORDER_FIELDS)
            const_set(:ALLOWED_ORDER_FIELDS, %w[name created_at updated_at rating price_range])
          end
  
          unless const_defined?(:DEFAULT_ORDER)
            const_set(:DEFAULT_ORDER, { field: 'created_at', direction: 'desc' }.freeze)
          end
        end
  
        def parse_order_params
          order_field = params[:order_by] || DEFAULT_ORDER[:field]
          order_direction = params[:order_direction] || DEFAULT_ORDER[:direction]
  
          using_default = false
          message = nil
  
          unless valid_order_field?(order_field)
            order_field = DEFAULT_ORDER[:field]
            using_default = true
            message = "Invalid sorting parameters. Using default sorting."
          end
  
          unless valid_order_direction?(order_direction)
            order_direction = DEFAULT_ORDER[:direction]
            using_default = true
            message = "Invalid sorting parameters. Using default sorting."
          end
  
          [order_field, order_direction, using_default, message]
        end
  
        def valid_order_field?(field)
          ALLOWED_ORDER_FIELDS.include?(field)
        end
  
        def valid_order_direction?(direction)
          ['asc', 'desc'].include?(direction.to_s.downcase)
        end
  
        def apply_filters(scope)
          scope = scope.search_by_full_text(params[:search]) if params[:search].present?
          scope = scope.tagged_with(params[:tag]) if params[:tag].present?
          scope
        end
  
        def apply_ordering(scope, field, direction)
          case field
          when 'distance'
            if params[:latitude].present? && params[:longitude].present?
              @user_location = [params[:latitude].to_f, params[:longitude].to_f]
              scope = scope.order_by_distance_from(@user_location)
              scope = scope.reorder("distance #{direction}") if direction != 'asc'
            end
          when 'created_at'
            scope = scope.order(created_at: direction)
          else
            scope = scope.order(Arel.sql("LOWER(COALESCE(restaurants.#{field}, google_restaurants.#{field})) #{direction}, restaurants.id"))
          end
          scope
        end
      end
    end
  end