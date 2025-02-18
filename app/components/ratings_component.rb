# frozen_string_literal: true

class RatingsComponent < ViewComponent::Base
    def initialize(rating: nil, form: nil, readonly: false, size: :md)
      @rating = rating.to_i  # Convert to integer, nil becomes 0
      @form = form
      @readonly = readonly
      @size = size
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
      content_tag(:div, class: "flex items-center") do
        (1..5).map do |i|
          star_svg(i <= @rating ? "text-yellow-400" : "text-gray-500")
        end.join.html_safe
      end
    end

    def render_editable_stars
      content_tag(:div, class: "flex items-center", data: { controller: "ratings" }) do
        star_buttons +
        (@form.hidden_field(:rating, data: { "ratings-target": "input" }) if @form)
      end
    end

    def star_buttons
      (1..5).map do |i|
        button_tag(type: "button",
                   class: star_classes(i),
                   data: {
                     action: "click->ratings#setRating mouseover->ratings#hoverRating mouseout->ratings#resetRating",
                     ratings_target: "star",
                     value: i
                   }) do
          star_svg
        end
      end.join.html_safe
    end

    def star_classes(index)
      classes = [ "inline-flex justify-center items-center rounded-full" ]
      classes << size_class
      classes << (@rating && index <= @rating ? "text-yellow-400" : "text-gray-500")
      classes.join(" ")
    end

    def size_class
      case @size
      when :sm
        "size-4"
      when :lg
        "size-6"
      else # :md
        "size-5"
      end
    end

    def star_svg(color_class = nil)
      content_tag(:svg, class: "shrink-0 #{size_class} #{color_class}", xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", fill: "currentColor", viewBox: "0 0 16 16") do
        tag(:path, d: "M3.612 15.443c-.386.198-.824-.149-.746-.592l.83-4.73L.173 6.765c-.329-.314-.158-.888.283-.95l4.898-.696L7.538.792c.197-.39.73-.39.927 0l2.184 4.327 4.898.696c.441.062.612.636.282.95l-3.522 3.356.83 4.73c.078.443-.36.79-.746.592L8 13.187l-4.389 2.256z")
      end
    end
end
