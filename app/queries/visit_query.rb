class VisitQuery
  ALLOWED_ORDER_FIELDS = %w[date rating price_paid_cents created_at updated_at restaurant_name].freeze
  DEFAULT_ORDER = { field: "date", direction: "desc" }.freeze

  attr_reader :relation, :params

  def initialize(relation = Visit.all, params = {})
    @relation = relation
    @params = params
  end

  def call
    scoped = relation
    scoped = filter_by_user(scoped)
    scoped = search(scoped) if params[:search].present?
    scoped = sort(scoped)
    scoped
  end

  private

  def filter_by_user(scoped)
    params[:user] ? scoped.where(user_id: params[:user].id) : scoped
  end

  def search(scoped)
    query = "%#{sanitize_sql_like(params[:search])}%"

    scoped.joins("LEFT JOIN restaurants ON visits.restaurant_id = restaurants.id")
          .joins("LEFT JOIN cuisine_types ON restaurants.cuisine_type_id = cuisine_types.id")
          .joins("LEFT JOIN visit_contacts ON visits.id = visit_contacts.visit_id")
          .joins("LEFT JOIN contacts ON visit_contacts.contact_id = contacts.id")
          .where(
            "restaurants.name ILIKE :query OR " \
            "restaurants.address ILIKE :query OR " \
            "contacts.name ILIKE :query OR " \
            "contacts.email ILIKE :query OR " \
            "cuisine_types.name ILIKE :query",
            query: query
          ).distinct
  end

  def sort(scoped)
    order_field = params[:order_by] || DEFAULT_ORDER[:field]
    order_direction = params[:order_direction]&.downcase || DEFAULT_ORDER[:direction]

    return scoped unless ALLOWED_ORDER_FIELDS.include?(order_field)

    case order_field
    when "restaurant_name"
      scoped.joins("LEFT JOIN restaurants ON visits.restaurant_id = restaurants.id")
            .select("visits.*")
            .order(Arel.sql("restaurants.name #{order_direction} NULLS LAST, visits.id"))
    else
      scoped.order(order_field => order_direction)
    end
  end

  def sanitize_sql_like(string)
    string.to_s.gsub(/[\\%_]/) { |m| "\\#{m}" }
  end
end
