# frozen_string_literal: true

class S3ImageComponent < ViewComponent::Base
    attr_reader :image, :size, :format, :quality, :fit, :html_class
  
    def initialize(image:, size: :medium, format: :webp, quality: 80, fit: "cover", html_class: nil)
      @image = image
      @size = size
      @format = format
      @quality = quality
      @fit = fit
      @html_class = html_class
    end
  
    def call
      image_tag(
        cloudflare_url,
        class: html_class,
        alt: "Image",
        loading: "lazy"
      )
    end
  
    private
  
    def image_dimensions
      case size
      when :original then nil
      when :thumbnail then { width: 100, height: 100 }
      when :small then { width: 300, height: 200 }
      when :medium then { width: 600, height: 400 }
      when :large then { width: 1200, height: 800 }
      else
        size.is_a?(Hash) ? size : { width: size }
      end
    end
  
    def cloudflare_url
      original_url = url_for(image)
      return original_url if size == :original || Rails.env.development?
  
      dimensions = image_dimensions
      params = []
      
      params << "width=#{dimensions[:width]}" if dimensions&.dig(:width)
      params << "height=#{dimensions[:height]}" if dimensions&.dig(:height)
      params << "format=#{format}" if format
      params << "quality=#{quality}" if quality
      params << "fit=#{fit}" if fit
  
      uri = URI(original_url)
      path_parts = uri.path.split('/')
      path_parts.insert(1, "cdn-cgi/image/#{params.join(',')}")
      uri.path = path_parts.join('/')
      
      transformed_url = uri.to_s
      Rails.logger.info "Transformed URL: #{transformed_url}"
      transformed_url
    end
  end