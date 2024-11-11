class ListMarkdownExporter
  def initialize(list)
    @list = list
  end

  def generate
    [
      header,
      metadata,
      restaurants_list
    ].join("\n\n")
  end

  private

  def header
    "# #{@list.name}\n" + 
    (@list.description.present? ? "\n#{@list.description}" : "")
  end

  def metadata
    [
      "## List Information",
      "- Total restaurants: #{@list.total_restaurants}",
      "- Visited: #{@list.visited_count} of #{@list.total_restaurants} (#{@list.visited_percentage}%)",
      "- Last updated: #{I18n.l(@list.last_updated_at, format: :long)}",
      "- Visibility: #{@list.visibility}"
    ].join("\n")
  end

  def restaurants_list
    [
      "## Restaurants",
      @list.restaurants.includes(:cuisine_type).order(:name).map do |restaurant|
        [
          "### #{restaurant.name}",
          restaurant.cuisine_type ? "- Cuisine: #{restaurant.cuisine_type.name}" : nil,
          restaurant.rating ? "- Rating: #{restaurant.rating}/5" : nil,
          restaurant.price_level ? "- Price: #{restaurant.price_level_display}" : nil,
          "- Address: #{restaurant.combined_address}",
          restaurant.combined_phone_number ? "- Phone: #{restaurant.combined_phone_number}" : nil,
          restaurant.notes.present? ? "\n#{restaurant.notes}" : nil,
          restaurant.combined_url ? "\n#{restaurant.combined_url}" : nil
        ].compact.join("\n")
      end
    ].join("\n\n")
  end
end
