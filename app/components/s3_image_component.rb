# frozen_string_literal: true

class S3ImageComponent < ViewComponent::Base
    attr_reader :image, :size, :html_class
  
    def initialize(image:, size: :medium, html_class: nil)
      @image = image
      @size = size
      @html_class = html_class
    end
  
    def call
      return unless image&.attached?

      # Return original image if size is :original
      if size == :original
        return image_tag(
          image,
          class: html_class,
          alt: "Image",
          loading: "lazy"
        )
      end

      # Find existing variant record
      variant_key = variant_options
      variant_record = ActiveStorage::VariantRecord.find_by(
        blob: image.blob,
        variation_digest: ActiveStorage::Variation.wrap(variant_key).digest
      )

      # Use existing variant or wait for it to be processed
      variant = variant_record ? variant_record.image : image.variant(variant_key)
      
      image_tag(
        variant,
        class: html_class,
        alt: "Image",
        loading: "lazy"
      )
    end
  
    private
  
    # Define variant options for different sizes
    # These will be used to generate variants on-demand when first requested
    def variant_options
      case size
      when :thumbnail then { resize_to_fill: [100, 100], format: :webp, saver: { quality: 80 } }
      when :small then { resize_to_limit: [300, 200], format: :webp, saver: { quality: 80 } }
      when :medium then { resize_to_limit: [600, 400], format: :webp, saver: { quality: 80 } }
      when :large then { resize_to_limit: [1200, 800], format: :webp, saver: { quality: 80 } }
      else {}
      end
    end
  end