# frozen_string_literal: true

class PreprocessAvatarService
  THUMBNAIL_SIZE = [120, 120].freeze
  MEDIUM_SIZE = [600, 600].freeze
  THUMBNAIL_QUALITY = 80
  MEDIUM_QUALITY = 85
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif].freeze
  MAX_FILE_SIZE = 10.megabytes

  class << self
    def call(upload)
      new(upload).process
    end
  end

  def initialize(upload)
    @upload = upload
    @errors = []
  end

  def process
    Rails.logger.debug "Processing avatar: size=#{@upload&.size}, content_type=#{@upload&.content_type}"
    return failure_response("No file uploaded") if @upload.nil?
    return failure_response("File too large") if @upload.size > MAX_FILE_SIZE
    return failure_response("Invalid file type") unless valid_content_type?

    begin
      process_variants
      success_response
    rescue StandardError => e
      Rails.logger.error "Avatar preprocessing error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      failure_response("Error processing image: #{e.message}")
    end
  end

  private

  def process_variants
    Rails.logger.debug "Creating variants..."
    @processed_image = {
      thumbnail: process_variant(THUMBNAIL_SIZE, THUMBNAIL_QUALITY),
      medium: process_variant(MEDIUM_SIZE, MEDIUM_QUALITY)
    }
    Rails.logger.debug "Variants created successfully"
  end

  def process_variant(size, quality)
    Rails.logger.debug "Processing variant: size=#{size}, quality=#{quality}"
    
    # Handle both ActionDispatch::Http::UploadedFile and Tempfile
    source_path = @upload.respond_to?(:tempfile) ? @upload.tempfile.path : @upload.path
    Rails.logger.debug "Source path: #{source_path}"
    
    processed = ImageProcessing::MiniMagick
      .source(source_path)
      .resize_to_limit(size[0], size[1])
      .convert("webp")
      .saver(quality: quality)
      .call

    Rails.logger.debug "Variant processed, path: #{processed.path}"
    
    {
      io: File.open(processed.path),
      filename: "#{File.basename(@upload.original_filename || @upload.path, '.*')}.webp",
      content_type: 'image/webp'
    }
  end

  def valid_content_type?
    result = ALLOWED_CONTENT_TYPES.include?(@upload.content_type)
    Rails.logger.debug "Content type check: #{@upload.content_type} - #{result ? 'valid' : 'invalid'}"
    result
  end

  def success_response
    {
      success: true,
      variants: @processed_image
    }
  end

  def failure_response(error_message)
    Rails.logger.debug "Failure: #{error_message}"
    {
      success: false,
      error: error_message
    }
  end
end
