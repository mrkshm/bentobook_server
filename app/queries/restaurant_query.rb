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
      scoped = scoped.joins(:google_restaurant)
      scoped = filter_by_user(scoped)
      scoped = search(scoped)
      scoped = filter_by_tag(scoped)
      scoped = sort(scoped)
      scoped.order(:id)
    end

    private

    def filter_by_user(scoped)
      params[:user] ? scoped.where(user_id: params[:user].id) : scoped
    end

    def search(scoped)
      if params[:search].present?
        scoped.search_by_full_text(params[:search])
      else
        scoped
      end
    end

    def filter_by_tag(scoped)
      params[:tag].present? ? scoped.tagged_with(params[:tag]) : scoped
    end

    def sort(scoped)
      order_field = params[:order_by] || DEFAULT_ORDER[:field]
      order_direction = params[:order_direction] || DEFAULT_ORDER[:direction]

      case order_field
      when "distance"
        sort_by_distance(scoped)
      when "created_at"
        scoped.order(restaurants: { created_at: order_direction })
      when "rating"
        scoped.order(restaurants: { rating: order_direction })
      when "price_level"
        scoped.order(restaurants: { price_level: order_direction })
      else
        scoped.order(Arel.sql("LOWER(restaurants.name) #{order_direction}, LOWER(google_restaurants.name) #{order_direction}"))
      end
    end

    def sort_by_distance(scoped)
      return scoped unless params[:latitude].present? && params[:longitude].present?

      scoped.by_distance(
        origin: [params[:latitude].to_f, params[:longitude].to_f]
      )
    end
end
