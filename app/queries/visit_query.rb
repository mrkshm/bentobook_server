class VisitQuery
  ALLOWED_ORDER_FIELDS = %w[date rating price_paid_cents created_at updated_at].freeze
  DEFAULT_ORDER = { field: 'date', direction: 'desc' }.freeze

  attr_reader :relation, :params

  def initialize(relation = Visit.all, params = {})
    @relation = relation
    @params = params
  end

  def call
    scoped = relation
    scoped = filter_by_user(scoped)
    scoped = sort(scoped)
    scoped
  end

  private

  def filter_by_user(scoped)
    params[:user] ? scoped.where(user_id: params[:user].id) : scoped
  end

  def sort(scoped)
    order_field = params[:order_by] || DEFAULT_ORDER[:field]
    order_direction = params[:order_direction] || DEFAULT_ORDER[:direction]

    return scoped unless ALLOWED_ORDER_FIELDS.include?(order_field)

    scoped.order(order_field => order_direction)
  end
end
