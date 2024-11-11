class ListMarkdownExporter
  def initialize(list, options = {})
    @list = list
    @options = options
    @include_stats = options.fetch(:include_stats, true)
    @include_notes = options.fetch(:include_notes, true)
  end

  def generate
    sections = [header]
    sections << metadata if @include_stats
    sections << restaurants_list
    sections.join("\n\n")
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
        restaurant_details(restaurant)
      end
    ].join("\n\n")
  end

  def restaurant_details(restaurant)
    details = [
      "### #{restaurant.name}",
      restaurant.cuisine_type ? "- Cuisine: #{restaurant.cuisine_type.name}" : nil,
      restaurant.rating ? "- Rating: #{restaurant.rating}/5" : nil,
      restaurant.price_level ? "- Price: #{restaurant.price_level_display}" : nil,
      "- Address: #{restaurant.combined_address}",
      restaurant.combined_phone_number ? "- Phone: #{restaurant.combined_phone_number}" : nil
    ]

    if @include_notes && restaurant.notes.present?
      details << "\n#{restaurant.notes}"
    end

    details << "\n#{restaurant.combined_url}" if restaurant.combined_url
    
    details.compact.join("\n")
  end
end
