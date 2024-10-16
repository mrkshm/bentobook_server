class RestaurantQuery
    ALLOWED_ORDER_FIELDS = %w[name address created_at updated_at distance].freeze
    DEFAULT_ORDER = { field: 'name', direction: 'asc' }.freeze

    attr_reader :relation, :params

    def initialize(relation = Restaurant.all, params = {})
      @relation = relation
      @params = params
    end
  
    def call
      scoped = relation
      scoped = filter_by_user(scoped)
      scoped = search(scoped)
      scoped = filter_by_tag(scoped)
      scoped = sort(scoped)
      scoped
    end
  
    private
  
    def filter_by_user(scoped)
      if params[:user]
        scoped.where(user: params[:user])
      else
        scoped
      end
    end
  
    def search(scoped)
      if params[:search].present?
        scoped.search_by_full_text(params[:search])
      else
        scoped
      end
    end
  
    def filter_by_tag(scoped)
      if params[:tag].present?
        scoped.tagged_with(params[:tag])
      else
        scoped
      end
    end
  
    def sort(scoped)
      order_field = params[:order_by] || 'name'
      order_direction = params[:order_direction] || 'asc'
  
      case order_field
      when 'distance'
        sort_by_distance(scoped)
      when 'created_at'
        scoped.order(created_at: order_direction)
      else
        scoped.order(Arel.sql("LOWER(COALESCE(restaurants.name, google_restaurants.name)) #{order_direction}"))
      end
    end
  
    def sort_by_distance(scoped)
      if params[:latitude].present? && params[:longitude].present?
        user_location = [params[:latitude].to_f, params[:longitude].to_f]
        scoped.near(user_location, 550_000, units: :km)
             .order("distance #{params[:order_direction] || 'asc'}")
      else
        scoped
      end
    end
  end