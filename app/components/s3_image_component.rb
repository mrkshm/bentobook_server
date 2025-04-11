# frozen_string_literal: true

class S3ImageComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :image, :size, :data

  def initialize(image:, size: :medium, html_class: nil, data: {})
    @image = image
    @size = size
    @html_class = html_class
    @data = data
  end

  def call
    return unless valid_image?

    image_tag(
      url_for_image,
      class: html_class,
      data: @data,
      loading: "lazy",
      decoding: "async",
      alt: "Image"
    )
  end

  # Make this public so we can check before trying to render
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

  # URL generation is only safe during rendering
  def url_for_image
    url = if @size == :original
      generate_original_url
    else
      generate_variant_url
    end

    url || raise(ArgumentError, "Unable to generate URL for image")
  end

  private

  def generate_original_url
    if @image.respond_to?(:file) && @image.file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(@image.file)
    elsif @image.respond_to?(:attached?) && @image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(@image)
    elsif @image.is_a?(ActiveStorage::VariantWithRecord) || @image.is_a?(ActiveStorage::Variant)
      Rails.application.routes.url_helpers.rails_blob_url(@image.blob)
    end
  end

  def generate_variant_url
    if @image.respond_to?(:file) && @image.file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(@image.file.variant(variant_options))
    elsif @image.respond_to?(:attached?) && @image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(@image.variant(variant_options))
    elsif @image.is_a?(ActiveStorage::VariantWithRecord) || @image.is_a?(ActiveStorage::Variant)
      Rails.application.routes.url_helpers.rails_blob_url(@image)
    end
  end

  def html_class
    [ @html_class, "s3-image", "s3-image-#{@size}" ].compact.join(" ")
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
      {} # Default empty options
    end
  end
end
