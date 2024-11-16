class ListStatistics
  def initialize(list:, user:)
    @list = list
    @user = user
  end

  def total_restaurants
    @total_restaurants ||= list.restaurants.count
  end

  def visited_count
    @visited_count ||= list.restaurants.joins(:visits)
                          .where(visits: { user_id: user.id })
                          .distinct.count
  end

  def visited_percentage
    return 0 if total_restaurants.zero?
    (visited_count.to_f / total_restaurants * 100).round
  end

  def last_visited_at
    @last_visited_at ||= list.restaurants
                            .joins(:visits)
                            .where(visits: { user_id: user.id })
                            .maximum('visits.created_at')
  end

  private

  attr_reader :list, :user
end
