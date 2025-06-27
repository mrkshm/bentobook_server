class RestaurantQuery
    ALLOWED_ORDER_FIELDS = %w[name address created_at updated_at distance rating price_level].freeze
    DEFAULT_ORDER = { field: "name", direction: "asc" }.freeze

    attr_reader :relation, :params

    def initialize(relation = Restaurant.all, params = {})
      @relation = relation
      @params = params
    end

    def call
      scoped = relation
      scoped = scoped.left_joins(:google_restaurant)
      scoped = filter_by_organization(scoped)
      scoped = search(scoped)
      scoped = filter_by_tag(scoped)
      scoped = sort(scoped)
      # Remove the default order(:id) as it can override our custom sorting
      scoped
    end

    private

    def filter_by_organization(scoped)
      params[:organization] ? scoped.where(organization_id: params[:organization].id) : scoped
    end

    def search(scoped)
      if params[:search].present?
        scoped.search(params[:search], params[:organization])
      else
        scoped
      end
    end

    def filter_by_tag(scoped)
      params[:tag].present? ? scoped.tagged_with(params[:tag]) : scoped
    end

    def sort(scoped)
      # If we have forced IDs, we'll handle the ordering manually after fetching
      return scoped if params[:force_ids].present?

      order_field = params[:order_by] || DEFAULT_ORDER[:field]
      order_direction = params[:order_direction] || DEFAULT_ORDER[:direction]

      case order_field
      when "distance"
        sort_by_distance(scoped)
      when "created_at"
        scoped.reorder(created_at: order_direction, id: :asc)
      when "rating"
        scoped.reorder(rating: order_direction, id: :asc)
      when "price_level"
        scoped.reorder(price_level: order_direction, id: :asc)
      else
        scoped.reorder(Arel.sql("LOWER(restaurants.name) #{order_direction}"), id: :asc)
      end
    end

    def sort_by_distance(scoped)
      return scoped unless params[:latitude].present? && params[:longitude].present?

      lat = params[:latitude].to_f
      lon = params[:longitude].to_f

      # Calculate distance with consistent precision
      distance_sql = <<~SQL.squish
        CAST(ROUND(
          SQRT(
            POW(CAST(restaurants.latitude AS DECIMAL(15, 10)) - #{lat}, 2) +#{' '}
            POW(CAST(restaurants.longitude AS DECIMAL(15, 10)) - #{lon}, 2)
          ),#{' '}
          8
        ) AS DECIMAL(15, 8))
      SQL

      # Select with the distance calculation and order by it
      scoped = scoped.select("restaurants.*, #{distance_sql} as distance")

      # Order by the calculated distance and ID
      scoped.reorder(Arel.sql("#{distance_sql} ASC, restaurants.id ASC"))
    end
end
