class ImageProcessorService
  def initialize(record, images)
    @record = record
    @images = Array(images).compact
    @logger = Rails.logger
  end

  def process
    return Result.new(success: true) unless @images.present?
    
    @logger.info "Processing #{@images.length} images"
    
    @images.each do |image|
      # Skip if image is not a proper file upload
      next unless valid_image?(image)
      
      @record.images.create!(file: image)
    end
    
    Result.new(success: true)
  rescue StandardError => e
    @logger.error "Image processing failed: #{e.message}"
    Result.new(success: false, error: I18n.t('errors.images.processing_failed'))
  end

  private

  def valid_image?(image)
    return false unless image.respond_to?(:content_type) && image.respond_to?(:original_filename)
    return false unless image.content_type&.start_with?('image/')
    
    true
  rescue StandardError => e
    @logger.error "Image validation failed: #{e.message} for image: #{image.inspect}"
    false
  end

  class Result
    attr_reader :error

    def initialize(success:, error: nil)
      @success = success
      @error = error
    end

    def success?
      @success
    end
  end
end
