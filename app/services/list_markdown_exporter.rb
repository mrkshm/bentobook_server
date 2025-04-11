class ListMarkdownExporter
  def initialize(list)
    @list = list
    @statistics = ListStatistics.new(list: list, user: list.creator)
  end

  def generate
    [
      *metadata,
      "",
      "## Restaurants",
      *restaurants
    ].join("\n")
  end

  private

  def metadata
    [
      "# #{@list.name}",
      "",
      "## Metadata",
      "- Total restaurants: #{@statistics.total_restaurants}",
      "- Visited: #{@statistics.visited_count} of #{@statistics.total_restaurants} (#{@statistics.visited_percentage}%)",
      "- Created: #{I18n.l(@list.created_at.to_date)}",
      "- Last visited: #{@statistics.last_visited_at ? I18n.l(@statistics.last_visited_at.to_date) : 'Never'}"
    ]
  end

  def restaurants
    @list.restaurants.order(:name).map do |restaurant|
      "- #{restaurant.name} (#{restaurant.cuisine_type&.name || 'Unknown cuisine'})"
    end
  end
end
