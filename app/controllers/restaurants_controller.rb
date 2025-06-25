class RestaurantsController < ApplicationController
  include ActionView::RecordIdentifier
  include RestaurantManagement
  include Pagy::Backend
  include CuisineTypeValidation

  # Make pagy_array available in the controller
  helper_method :pagy_array

  before_action :authenticate_user!
  before_action :set_restaurant, only: [ :show, :edit, :update, :destroy, :update_price_level, :edit_images ]

  def index
    logger.debug "\n#{'='*80}"
    logger.debug "===== DEBUG: Starting restaurants#index ====="
    logger.debug "Format: #{request.format.try(:symbol)}"
    logger.debug "Params: #{params.except(:controller, :action).inspect}"
    logger.debug "Turbo Frame?: #{request.headers['Turbo-Frame'].present?}"
    logger.debug "Turbo Frame ID: #{request.headers['Turbo-Frame']}"
    logger.debug "#{'='*80}"

    order_params = parse_order_params
    return if performed?


    items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 12
    page = params[:page].to_i.positive? ? params[:page].to_i : 1

    # Start with the base scope
    restaurants_scope = Current.organization.restaurants.with_google.includes(:visits, :cuisine_type, :tags)

    # Log the initial scope - don't use to_sql as it can cause issues with complex queries
    puts "\n===== Initial scope ====="
    puts "Restaurants scope class: #{restaurants_scope.class}"
    puts "Restaurants scope includes: #{restaurants_scope.includes_values.inspect}"
    puts "Restaurants scope where: #{restaurants_scope.where_clause.inspect}"

    # Merge all query parameters for the view and pagination
    @query_params = {
      search: params[:search],
      tag: params[:tag],
      order_by: params[:order_by],
      order_direction: params[:order_direction],
      per_page: items_per_page
    }.compact

    # Add location params if present for distance sorting
    if params[:latitude].present? && params[:longitude].present?
      @query_params[:latitude] = params[:latitude].to_f
      @query_params[:longitude] = params[:longitude].to_f
    end

    # Apply search and filters first
    query_params = search_params.merge(order_params)
    logger.debug "\nQuery params: #{query_params.inspect}"

    # For distance sorting, we'll handle pagination differently
    lat_param = params[:latitude] || params[:lat]
    lng_param = params[:longitude] || params[:lng]

    if params[:order_by] == "distance" && lat_param.present? && lng_param.present?
      logger.debug "\n===== Processing distance-based sorting ====="

      # ---------------------------------------------------------------------
      # 1. Build a flat scope with all search / filter conditions but WITHOUT
      #    heavy includes – duplicates are removed with DISTINCT.
      # ---------------------------------------------------------------------
      base_scope = RestaurantQuery.new(restaurants_scope, query_params.except(:order_by, :order_direction)).call
      # Strip any ORDER BY clauses to avoid PG DISTINCT/ORDER conflict, then collect unique IDs in Ruby
      ids = base_scope.reorder(nil).pluck(:id).uniq

      logger.debug "Unique IDs after filtering (#{ids.size}): #{ids.inspect}"

      # ---------------------------------------------------------------------
      # 2. Calculate distances in Ruby – faster than battling PG DISTINCT/ORDER.
      # ---------------------------------------------------------------------
      lat = lat_param.to_f
      lng = lng_param.to_f

      coords = Restaurant.where(id: ids).pluck(:id, :latitude, :longitude)

      distance_for = ->(lat1, lon1) {
        next Float::INFINITY if lat1.nil? || lon1.nil?
        Math.sqrt((lat1 - lat)**2 + (lon1 - lng)**2)
      }

      ordered_ids = coords.sort_by { |id_, lat1, lon1| distance_for.call(lat1, lon1) } .map(&:first)

      # Append restaurants with no coordinates at the end (keep original order)
      no_coord_ids = ids - ordered_ids
      ordered_ids.concat(no_coord_ids)

      logger.debug "Ordered IDs by distance: #{ordered_ids.inspect}"

      # ---------------------------------------------------------------------
      # 3. Paginate the ordered ID list using Pagy on a Ruby array.
      # ---------------------------------------------------------------------
      @pagy = Pagy.new(count: ordered_ids.size, page: page, items: items_per_page)
      offset = (@pagy.page - 1) * items_per_page
      page_ids = ordered_ids.slice(offset, items_per_page) || []
      logger.debug "Page IDs: #{page_ids.inspect}"

      # ---------------------------------------------------------------------
      # 4. Fetch restaurants for page, preserve order.
      # ---------------------------------------------------------------------
      restaurants_page = Restaurant.where(id: page_ids)
                                   .includes(:visits, :cuisine_type, :tags)
                                   .index_by(&:id)
      @restaurants = page_ids.map { |rid| restaurants_page[rid] }.compact

      respond_to do |format|
        format.html
        format.turbo_stream
      end
      return
      query = RestaurantQuery.new(restaurants_scope, query_params).call

      # Log query info without using to_sql
      puts "\n===== Distance Query ====="
      puts "Query class: #{query.class}"
      puts "Query includes: #{query.includes_values.inspect if query.respond_to?(:includes_values)}"
      puts "Query where: #{query.where_clause.inspect if query.respond_to?(:where_clause)}"

      # Get count safely
      begin
        count = query.count
        puts "Total restaurants before pagination: #{count}"
      rescue => e
        puts "Error getting count: #{e.message}"
      end

      begin
        # Debug: Log all restaurants with distances before pagination
        debug_query = query.dup
        debug_results = debug_query.map { |r| [ r.id, r.name, r.try(:distance) ] }

        logger.debug "\n=== DEBUG: All restaurants with distances (sorted) ==="
        logger.debug "ID\tDistance\tName"
        logger.debug "-" * 80
        debug_results.each do |id, name, distance|
          logger.debug "#{id}\t#{distance.to_f.round(6)}\t#{name}"
        end
        logger.debug "Total: #{debug_results.size} restaurants"
        logger.debug "=" * 80
      rescue => e
        logger.error "Error logging restaurants: #{e.message}"
        logger.error e.backtrace.join("\n")
      end

      # For distance sorting, we need to ensure the distance calculation is included in the pagination
      # and that the ordering is maintained across pages
      puts "\nApplying pagination (page: #{page}, per_page: #{items_per_page})"

      # First, get all unique restaurant IDs with their calculated distance in a subquery
      lat = params[:lat].to_f if params[:lat].present?
      lng = params[:lng].to_f if params[:lng].present?

      if lat && lng
        # Use a subquery to calculate distances first, then order in the outer query
        distance_sql = "CAST(ROUND(SQRT(POW(CAST(restaurants.latitude AS DECIMAL(15, 10)) - #{lat}, 2) + " \
               "POW(CAST(restaurants.longitude AS DECIMAL(15, 10)) - #{lng}, 2)), 8) AS DECIMAL(15, 8))"

        # First get all restaurant IDs with coordinates, ordered by distance
        with_coords = query
          .where.not(latitude: nil, longitude: nil)
          .select("DISTINCT restaurants.id, #{distance_sql} AS distance")
          .to_sql

        # Then get the IDs ordered by distance
        ordered_with_coords = Restaurant.find_by_sql([
          "SELECT id FROM (#{with_coords}) AS subq ORDER BY distance #{params[:order_direction] == 'desc' ? 'DESC' : 'ASC'}"
        ]).map(&:id)

        # Get restaurants without coordinates to append at the end
        no_coords = query.where(latitude: nil).or(query.where(longitude: nil)).pluck(:id)

        # Combine both lists
        ordered_ids = ordered_with_coords + no_coords
      else
        # If no coordinates, just order by ID
        ordered_ids = query.distinct.order(:id).pluck(:id)
      end

      logger.debug "Ordered IDs: #{ordered_ids.inspect}"

      # Calculate total pages based on unique IDs
      total_pages = (ordered_ids.size.to_f / items_per_page).ceil
      logger.debug "Total pages: #{total_pages}, Current page: #{page}"

      # Manually paginate the IDs
      offset = (page - 1) * items_per_page
      paginated_ids = ordered_ids[offset, items_per_page] || []
      logger.debug "Paginated IDs: #{paginated_ids.inspect}"

      # Create a custom pagy object for the view
      @pagy = Pagy.new(count: ordered_ids.size, page: page, items: items_per_page)

      # Fetch restaurants by the paginated IDs while preserving order
      @restaurants = Restaurant.where(id: paginated_ids)
        .includes(:visits, :cuisine_type, :tags)
        .order(Arel.sql("array_position(ARRAY[#{paginated_ids.join(',')}]::bigint[], id::bigint)"))

      # Log pagination details
      logger.debug "\n===== PAGINATION DEBUG ====="
      logger.debug "Page: #{page}, Items per page: #{items_per_page}, Offset: #{offset}"
      logger.debug "Total items: #{ordered_ids.size}, Paginated IDs count: #{paginated_ids.size}"
      logger.debug "First 10 paginated IDs: #{paginated_ids.take(10).inspect}"
      logger.debug "Last 5 paginated IDs: #{paginated_ids.last(5).inspect}" if paginated_ids.size > 10

      # Create a pagy object for the view
      @pagy = Pagy.new(count: ordered_ids.size, page: page, items: items_per_page)

      # Finally, fetch the restaurants with their distances in the paginated order
      @restaurants = if paginated_ids.any?
        # If we're sorting by distance, we need to handle this specially
        if params[:order_by] == "distance" && params[:latitude].present? && params[:longitude].present?
          # For distance sorting, we need to fetch all restaurants with their distances
          # and then sort them in memory to maintain the correct order
          lat = params[:latitude].to_f
          lng = params[:longitude].to_f

          # Calculate distances for all restaurants in the current page
          restaurants = Restaurant.where(id: paginated_ids)
                                .includes(:visits, :cuisine_type, :tags)
                                .to_a
                                .sort_by do |r|
                                  if r.latitude.present? && r.longitude.present?
                                    lat_diff = r.latitude.to_f - lat
                                    lng_diff = r.longitude.to_f - lng
                                    Math.sqrt(lat_diff**2 + lng_diff**2)
                                  else
                                    Float::INFINITY
                                  end
                                end

          # Add the distance method to each restaurant
          restaurants.each do |restaurant|
            next unless restaurant.latitude.present? && restaurant.longitude.present?

            restaurant.define_singleton_method(:distance) do
              @distance ||= begin
                lat_diff = restaurant.latitude.to_f - lat
                lng_diff = restaurant.longitude.to_f - lng
                Math.sqrt(lat_diff**2 + lng_diff**2)
              end
            end
          end

          restaurants
        else
          # For non-distance sorting, fetch the restaurants in the paginated order
          logger.debug "\n===== FETCHING RESTAURANTS FOR PAGE #{page} ====="

          # 1. Log the paginated IDs we're about to fetch
          logger.debug "Fetching restaurants for IDs: #{paginated_ids.inspect}"

          # 2. Fetch all restaurants with their associations
          restaurants = Restaurant.where(id: paginated_ids)
                                .includes(:visits, :cuisine_type, :tags)
                                .to_a

          # 3. Log the fetched restaurants (before ordering)
          logger.debug "Fetched #{restaurants.size} restaurants with IDs: #{restaurants.map(&:id).inspect}"

          # 4. Order them according to paginated_ids
          restaurants_by_id = restaurants.index_by(&:id)
          restaurants = paginated_ids.map { |id| restaurants_by_id[id] }.compact

          # 5. Log the ordered restaurants
          logger.debug "Ordered restaurants: #{restaurants.map { |r| [ r.id, r.name ] }.inspect}"

          # 6. Apply any additional filters without re-sorting
          logger.debug "Applying additional filters..."
          filtered_restaurants = RestaurantQuery.new(
            Restaurant.where(id: restaurants.map(&:id)),
            query_params.merge(force_ids: true)
          ).call.includes(:visits, :cuisine_type, :tags).to_a

          # 7. Maintain the order after filtering
          filtered_by_id = filtered_restaurants.index_by(&:id)
          filtered_restaurants = restaurants.map { |r| filtered_by_id[r.id] }.compact

          # 8. Log final results
          logger.debug "Final filtered and ordered restaurants: #{filtered_restaurants.size} items"
          filtered_restaurants.each_with_index do |r, i|
            logger.debug "[#{i}] ID: #{r.id}, Name: #{r.name}"
          end

          filtered_restaurants
        end
      else
        []
      end

      # Log pagination info
      puts "\n===== Pagination ====="
      puts "Page: #{page}, Items per page: #{items_per_page}"
      puts "Total pages: #{@pagy.pages}" if @pagy.respond_to?(:pages)
      puts "Total items: #{@pagy.count}" if @pagy.respond_to?(:count)

      # Debug: Log paginated results
      begin
        puts "\n===== Paginated Results (page #{page}) ====="
        puts "ID\tDistance\tName"
        puts "-" * 80
        @restaurants.each do |r|
          puts "#{r.id}\t#{r.try(:distance).to_f.round(6)}\t#{r.name}"
        end
        puts "=" * 80
      rescue => e
        puts "\n!!! ERROR LOGGING PAGINATED RESULTS: #{e.message}"
        puts e.backtrace.take(5).join("\n")
      end
    else
      # For other sort orders, use the standard approach
      @restaurants = RestaurantQuery.new(restaurants_scope, query_params).call
      @pagy, @restaurants = pagy_countless(@restaurants, items: items_per_page, page: page)
    end

    @tags = ActsAsTaggableOn::Tag.most_used(10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id])
    @notes_edit = params[:notes_edit].present?
    @tags = @restaurant.tags || []

    # Handle specific turbo frame request for notes
    if turbo_frame_request? && request.headers["Turbo-Frame"] == "restaurant_#{@restaurant.id}_notes"
      render partial: "components/notes_component", locals: {
        record: @restaurant,
        notes_field: :notes,
        container_classes: "mt-4",
        notes_edit: @notes_edit
      }
      return
    end

    @all_tags = ActsAsTaggableOn::Tag.all
    @visits = @restaurant.visits

    if params[:modal] == "cuisine_type"
      Rails.logger.debug "Rendering cuisine type modal"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "modal",
            partial: "restaurants/cuisine_type_modal",
            locals: { restaurant: @restaurant }
          )
        end
        format.html
      end
      return
    end

    @lists = List.accessible_by(Current.user).containing_restaurant(@restaurant)

    if turbo_frame_request? && params[:turbo_frame] == dom_id(@restaurant, :notes)
      render partial: "components/notes_component", locals: {
        record: @restaurant,
        notes_field: :notes,
        container_classes: nil,
        notes_edit: @notes_edit
      }
    end
  end

  def edit
    @restaurant = Current.organization.restaurants.with_google.includes(:images).find(params[:id])
    load_edit_dependencies
  end

  def new
  end

  def new_confirm
    @google_restaurant = Restaurants::GooglePlaceImportService.find_or_create(place_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("restaurant_search", ""),
          turbo_stream.update(
            "restaurant_form",
            partial: "restaurants/new/restaurant_confirm",
            locals: { google_restaurant: @google_restaurant }
          )
        ]
      end
    end
  end

  def edit_images
    @images = @restaurant.images.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.turbo_stream # For Hotwire Native modal support
    end
  end

  def update
    @restaurant = Current.organization.restaurants.find(params[:id])
    load_edit_dependencies

    Rails.logger.debug "\n=== Controller Debug ==="
    Rails.logger.debug "Restaurant before update: #{@restaurant.inspect}"
    Rails.logger.debug "Update params: #{restaurant_params.inspect}"
    Rails.logger.debug "Request format: #{request.format}"
    Rails.logger.debug "Request accepts: #{request.accepts.map(&:to_s).join(', ')}"

    if @restaurant.update(restaurant_params)
      Rails.logger.debug "Update successful"
      respond_to do |format|
        format.turbo_stream do
          if restaurant_params.key?(:price_level)
            render turbo_stream: [
              turbo_stream.replace(
                dom_id(@restaurant, :price_level),
                partial: "restaurants/price_level",
                locals: { restaurant: @restaurant }
              ),
              turbo_stream.replace(
                "#{dom_id(@restaurant, :price_level)}_modal_container",
                partial: "restaurants/price_level_modal",
                locals: { restaurant: @restaurant }
              )
            ]
          elsif restaurant_params.key?(:cuisine_type_id)
            render turbo_stream: [
              turbo_stream.update("modal", ""),
              turbo_stream.replace(
                dom_id(@restaurant, :cuisine_type),
                partial: "restaurants/cuisine_type",
                locals: { restaurant: @restaurant }
              )
            ]
          end
        end
        format.html { redirect_to @restaurant, locale: I18n.locale }
        format.json { render json: @restaurant }
        format.any { head :not_acceptable }
      end
    else
      Rails.logger.debug "Update failed"
      Rails.logger.debug "Restaurant errors: #{@restaurant.errors.full_messages}"
      Rails.logger.debug "Cuisine types: #{@cuisine_types.inspect}"
      Rails.logger.debug "Flash before: #{flash.inspect}"

      flash.now[:alert] = @restaurant.errors.full_messages.join(", ")

      Rails.logger.debug "Flash after: #{flash.inspect}"
      Rails.logger.debug "=== End Controller Debug ==="

      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { head :unprocessable_entity }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
        format.any { head :not_acceptable }
      end
    end
  end

  def update_price_level
    @restaurant = Current.organization.restaurants.find(params[:id])

    if @restaurant.update(price_level: params[:restaurant][:price_level])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :price_level),
            partial: "restaurants/price_level",
            locals: { restaurant: @restaurant }
          )
        end
        format.html { redirect_to @restaurant, locale: I18n.locale }
        format.json { render json: { status: :ok, price_level: @restaurant.price_level } }
      end
    else
      head :unprocessable_entity
    end
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.organization = Current.organization

    Rails.logger.debug "\n=== Create Action Debug ==="
    Rails.logger.debug "Restaurant params: #{restaurant_params.inspect}"
    Rails.logger.debug "Request format: #{request.format}"

    if @restaurant.save
      Rails.logger.debug "Restaurant saved successfully"
      respond_to do |format|
        format.html { redirect_to restaurant_path(@restaurant, locale: I18n.locale), notice: "Restaurant was successfully created." }
        format.json { render json: @restaurant, status: :created, location: restaurant_path(@restaurant, locale: I18n.locale) }
      end
    else
      Rails.logger.debug "Restaurant save failed: #{@restaurant.errors.full_messages}"
      load_edit_dependencies
      flash.now[:alert] = @restaurant.errors.full_messages.join(", ")

      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @restaurant.destroy
    redirect_to restaurants_path, notice: "Restaurant was successfully removed from your list."
  end

  def search
    respond_to do |format|
      format.html { render partial: "search_form" }
      format.turbo_stream
    end
  end

  private

  def render_error_response
    if hotwire_native_app?
      render :edit_tags_native, status: :unprocessable_entity
    else
      render :edit_tags, status: :unprocessable_entity
    end
  end

  def parse_order_params
    order_field = params[:order_by] || RestaurantQuery::DEFAULT_ORDER[:field]
    order_direction = params[:order_direction] || RestaurantQuery::DEFAULT_ORDER[:direction]

    unless RestaurantQuery::ALLOWED_ORDER_FIELDS.include?(order_field)
      flash[:alert] = "Invalid order_by parameter. Using default sorting."
      order_field = RestaurantQuery::DEFAULT_ORDER[:field]
    end

    unless valid_order_direction?(order_direction)
      flash[:alert] = "Invalid order_direction parameter. Using default direction."
      order_direction = RestaurantQuery::DEFAULT_ORDER[:direction]
    end

    { order_by: order_field, order_direction: order_direction }
  end

  def valid_order_direction?(direction)
    [ "asc", "desc" ].include?(direction.to_s.downcase)
  end

  def search_params
    params.permit(:search, :tag, :latitude, :longitude, :lat, :lng,
                :order_by, :order_direction, :page, :per_page, :format, :locale)
          .merge(organization: Current.organization)
  end

  def restaurant_params
    # First get the regular permitted params
    permitted = params.require(:restaurant).permit(
      :name, :address, :notes, :cuisine_type_name, :cuisine_type_id,
      :rating, :price_level, :street_number, :street, :postal_code,
      :city, :state, :country, :phone_number, :url, :business_status,
      :tag_list, :google_restaurant_id, images: [],
      google_restaurant_attributes: [
        :google_place_id, :name, :address, :latitude, :longitude,
        :street_number, :street, :postal_code, :city, :state, :country,
        :phone_number, :url, :business_status, :google_rating,
        :google_ratings_total, :price_level, :opening_hours, :google_updated_at
      ],
      tags: []
    )

    # Handle the special case of images - filter out any empty strings or nil values
    if permitted[:images].present?
      # Only keep actual file uploads, reject empty strings and nil values
      permitted[:images] = Array(permitted[:images]).reject(&:blank?).select do |img|
        img.is_a?(ActionDispatch::Http::UploadedFile) && img.size.positive?
      end

      # If after filtering we have an empty array, remove the key entirely
      permitted.delete(:images) if permitted[:images].empty?
    end

    permitted
  end

  def restaurant_update_params
    params.require(:restaurant).permit(
      :name, :address, :notes, :cuisine_type_id, :cuisine_type_name,
      :rating, :price_level, :street_number, :street, :postal_code,
      :city, :state, :country, :phone_number, :url, :business_status,
      :tag_list, images: []
    ).tap do |whitelisted|
      Rails.logger.info "Whitelisted params: #{whitelisted.inspect}"
    end
  end

  def handle_failed_save
    load_edit_dependencies
    flash[:alert] = if @restaurant&.errors&.any?
                      @restaurant.errors.full_messages.join(", ")
    else
                      flash[:alert] # Keep existing flash message if no restaurant errors
    end
    render :new, status: :unprocessable_entity
  end

  def handle_invalid_cuisine_type
    load_edit_dependencies
    flash[:alert] = "Invalid cuisine type: #{restaurant_params[:cuisine_type_name]}. Available types: #{@cuisine_types.pluck(:name).join(', ')}"
    render :new, status: :unprocessable_entity
  end

  def set_restaurant
    # Use params[:restaurant_id] if it exists, otherwise fall back to params[:id]
    id = params[:restaurant_id] || params[:id]
    @restaurant = Current.organization.restaurants.find(id)
  end

  def place_params
    params.require(:place).permit(
      :google_place_id, :name, :formatted_address, :latitude, :longitude,
      :phone_number, :website, :rating, :user_ratings_total,
      :price_level, :business_status, :street_number, :street_name,
      :city, :state, :postal_code, :country
    )
  end

  def load_edit_dependencies
    @cuisine_types = CuisineType.all
  end
end
