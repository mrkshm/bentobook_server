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
      unless image.respond_to?(:content_type) && image.respond_to?(:original_filename)
        @logger.error "Image failed content_type check: #{image.class}"
        return Result.new(success: false, error: I18n.t('errors.images.processing_failed'))
      end
      
      @record.images.create!(file: image)
    end
    
    Result.new(success: true)
  rescue StandardError => e
    @logger.error "Image processing failed: #{e.message}"
    Result.new(success: false, error: I18n.t('errors.images.processing_failed'))
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
