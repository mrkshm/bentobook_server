# frozen_string_literal: true

class S3ImageComponent < ViewComponent::Base
  attr_reader :image, :size, :html_class, :data

  def initialize(image:, size: :medium, html_class: nil, data: {})
    @image = image
    @size = size
    @html_class = html_class
    @data = data
  end

  def call
    return unless @image&.attached?

    if @size == :original
      image_tag(@image, **html_options)
    else
      image_tag(@image.variant(variant_key), **html_options)
    end
  end

  private

  # Define variant options for different sizes
  def variant_key
    case @size
    when :thumbnail
      {
        resize_to_fill: [100, 100],
        format: :webp,
        saver: { quality: 80 }
      }
    when :small
      {
        resize_to_limit: [300, 200],
        format: :webp,
        saver: { quality: 80 }
      }
    when :medium
      {
        resize_to_limit: [600, 400],
        format: :webp,
        saver: { quality: 80 }
      }
    when :large
      {
        resize_to_limit: [1200, 800],
        format: :webp,
        saver: { quality: 80 }
      }
    else
      {}
    end
  end

  def html_class
    ["object-cover", @html_class].compact.join(" ")
  end

  def html_options
    {
      class: html_class,
      alt: "Image",
      loading: "lazy",
      data: @data,
      decoding: "async"
    }
  end
end