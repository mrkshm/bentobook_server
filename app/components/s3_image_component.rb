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
      decoding: "async"
    )
  end

  private

  def valid_image?
    @image.is_a?(ActiveStorage::Attached) ||
    @image.is_a?(ActiveStorage::VariantWithRecord) ||
    @image.is_a?(ActiveStorage::Variant)
  end

  def image_source
    @image.is_a?(ActiveStorage::Attached) ? @image.variant(variant_options) : @image
  end

  def html_class
    [ "object-cover", @html_class ].compact.join(" ")
  end

  def variant_options
    case @size
    when :thumbnail
      { resize_to_fill: [ 100, 100 ], format: :jpg }
    when :small
      { resize_to_limit: [ 300, 200 ], format: :jpg }
    when :medium
      { resize_to_limit: [ 600, 400 ], format: :jpg }
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :jpg }
    else
      {}
    end
  end
end
