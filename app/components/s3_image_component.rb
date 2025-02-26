# frozen_string_literal: true

class S3ImageComponent < ViewComponent::Base
  def initialize(image:, size: :medium, html_class: nil, data: {})
    @image = image
    @size = size
    @html_class = html_class
    @data = data
  end

  def call
    return unless valid_image?

    image_tag(
      image_source,
      class: html_class,
      data: @data,
      loading: "lazy",
      decoding: "async",
      alt: "Image" # Adding alt text for accessibility
    )
  end

  private

  def valid_image?
    return false unless @image.present?

    # Handle polymorphic Image model
    if @image.respond_to?(:file) && @image.file.attached?
      return true
    end

    # Handle direct ActiveStorage attachments
    if @image.respond_to?(:attached?) && @image.attached?
      return true
    end

    # Handle ActiveStorage variants
    @image.is_a?(ActiveStorage::VariantWithRecord) ||
    @image.is_a?(ActiveStorage::Variant)
  end

  def image_source
    # For our polymorphic Image model
    if @image.respond_to?(:file) && @image.file.attached?
      return @image.file.variant(variant_options)
    end

    # For direct ActiveStorage attachments
    if @image.respond_to?(:attached?) && @image.attached?
      return @image.variant(variant_options)
    end

    # For variants
    @image
  end

  def html_class
    [ "object-cover", @html_class ].compact.join(" ")
  end

  def variant_options
    case @size
    when :thumbnail
      { resize_to_fill: [ 100, 100 ], format: :webp, saver: { quality: 80 } }
    when :small
      { resize_to_limit: [ 300, 200 ], format: :webp, saver: { quality: 80 } }
    when :medium
      { resize_to_limit: [ 600, 400 ], format: :webp, saver: { quality: 80 } }
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :webp, saver: { quality: 80 } }
    when :original
      {} # Use the original format without resizing
    else
      {}
    end
  end
end
