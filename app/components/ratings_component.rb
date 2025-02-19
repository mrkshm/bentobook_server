# frozen_string_literal: true

class RatingsComponent < ViewComponent::Base
  include ActionView::RecordIdentifier

  def initialize(rating: nil, form: nil, readonly: false, size: :md, dom_id: nil, restaurant: nil)
    @rating = rating.to_i  # Convert to integer, nil becomes 0
    @form = form
    @readonly = readonly
    @size = size
    @dom_id = dom_id || (restaurant ? dom_id(restaurant, :rating) : nil)
    @restaurant = restaurant
  end

  def call
    if @readonly
      render_readonly_stars
    else
      render_editable_stars
    end
  end

  private

  def render_readonly_stars
    content_tag(:div, class: "flex items-center", id: @dom_id) do
      (1..5).map do |i|
        star_svg(i <= @rating ? "text-yellow-400" : "text-gray-500")
      end.join.html_safe
    end
  end

  def render_editable_stars
    # Render modal content at page level
    content_for :modals do
      render(ModalComponent.new(id: "#{@dom_id}_modal")) do |modal|
        modal.with_header { tag.h3("Rate this restaurant", class: "text-lg font-medium text-surface-900") }
        
        modal.with_body do
          tag.div(class: "flex items-center justify-center gap-4 py-4", 
                  data: { ratings_target: "starsContainer" }) do
            (1..5).map do |i|
              button_tag(type: "button",
                        class: "w-12 h-12 focus:outline-none transition-transform hover:scale-110",
                        data: { value: i,
                               action: "click->ratings#setRating",
                               ratings_target: "star" }) do
                star_svg(i <= @rating ? "text-yellow-400" : "text-gray-500", size: :lg)
              end
            end.join.html_safe
          end
        end
      end
    end

    # Render the stars button
    tag.div(class: "flex items-center", id: @dom_id, data: { controller: "ratings", ratings_url_value: @restaurant ? restaurant_path(@restaurant) : nil }) do
      content_tag(:button, type: "button", class: "flex items-center cursor-pointer focus:outline-none", data: { action: "click->ratings#openModal" }) do
        (1..5).map do |i|
          star_svg(i <= @rating ? "text-yellow-400" : "text-gray-500")
        end.join.html_safe
      end
    end
  end

  def star_svg(classes, size: @size)
    size_classes = {
      sm: "w-4 h-4",
      md: "w-5 h-5",
      lg: "w-8 h-8"
    }

    <<-SVG.strip.html_safe
      <svg class="#{size_classes[size]} #{classes} transition-colors" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
      </svg>
    SVG
  end
end
