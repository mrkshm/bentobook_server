module ImageHelper
  include Rails.application.routes.url_helpers
  # Helper to easily access our pre-generated image variants
  def image_variant_url(image, size)
    return nil unless image&.file&.attached?

    case size
    when :thumbnail
      variant = image.file.variant(
        resize_to_limit: [ 300, nil ],
        format: :webp,
        saver: { quality: 70 }
      )
      url_for(variant)
    when :small
      variant = image.file.variant(
        resize_to_limit: [ 600, nil ],
        format: :webp,
        saver: { quality: 75 }
      )
      url_for(variant)
    when :medium
      variant = image.file.variant(
        resize_to_limit: [ 1200, nil ],
        format: :webp,
        saver: { quality: 80 }
      )
      url_for(variant)
    when :large
      variant = image.file.variant(
        resize_to_limit: [ 2000, nil ],
        format: :webp,
        saver: { quality: 85 }
      )
      url_for(variant)
    when :fallback # For browsers without WebP support
      variant = image.file.variant(
        resize_to_limit: [ 1200, nil ]
      )
      url_for(variant)
    else
      # Return the original if no size matches
      url_for(image.file)
    end
  end

  # Helper for generating picture element with WebP and fallback sources
  def responsive_image_tag(image, alt: "", class_name: "", lazy: true)
    return "" unless image&.file&.attached?

    loading = lazy ? "lazy" : "eager"

    content_tag(:picture) do
      concat(
        content_tag(:source, "",
          srcset: image_variant_url(image, :small),
          media: "(max-width: 640px)",
          type: "image/webp"
        )
      )
      concat(
        content_tag(:source, "",
          srcset: image_variant_url(image, :medium),
          media: "(max-width: 1280px)",
          type: "image/webp"
        )
      )
      concat(
        content_tag(:source, "",
          srcset: image_variant_url(image, :large),
          type: "image/webp"
        )
      )
      concat(
        content_tag(:source, "",
          srcset: image_variant_url(image, :fallback)
        )
      )
      concat(
        image_tag(image.file,
          alt: alt,
          class: class_name,
          loading: loading
        )
      )
    end
  end
end
