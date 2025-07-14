# frozen_string_literal: true

class PreprocessAvatarService
  MAX_FILE_SIZE = 20.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  OUTPUT_FORMAT = "webp"
  OUTPUT_CONTENT_TYPE = "image/webp"
  OUTPUT_EXTENSION = ".webp"
  MIN_QUALITY = 1
  MAX_QUALITY = 100

  VARIANTS = {
    thumbnail: {
      size: [ 100, 100 ],
      quality: 80,
      suffix: :thumb
    }.freeze,
    medium: {
      size: [ 400, 400 ],
      quality: 90,
      suffix: :md
    }.freeze
  }.freeze

  class << self
    def call(upload_file)
      new(upload_file).process
    end

    private

    def failure_response(error)
      { success: false, error: error }
    end
  end

  def initialize(upload_file)
    @upload = upload_file
    @variants = {}
  end

  def process
    validate_upload!
    process_all_variants
    { success: true, variants: @variants }
  rescue StandardError => e
    Rails.logger.error "Avatar preprocessing error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    self.class.send(:failure_response, e.message)
  end

  private

  def validate_upload!
    raise "No file uploaded" if @upload.nil?

    # Check if it's an uploaded file with proper methods
    if @upload.respond_to?(:size)
      raise "File too large" if @upload.size > MAX_FILE_SIZE
    end

    if @upload.respond_to?(:content_type)
      raise "Invalid file type" unless ALLOWED_CONTENT_TYPES.include?(@upload.content_type)
    end
  end

  def process_all_variants
    VARIANTS.each do |variant_name, config|
      Rails.logger.info "Processing #{variant_name} variant..."
      @variants[variant_name] = process_variant(
        config[:suffix],
        config[:size],
        config[:quality]
      )
      Rails.logger.info "Successfully processed #{variant_name} variant"
    end
  end

  def process_variant(suffix, size, quality)
    validate_quality!(quality)
    Rails.logger.debug "Processing variant: size=#{size}, quality=#{quality}"

    # Handle both ActionDispatch::Http::UploadedFile and Tempfile
    source_path = @upload.respond_to?(:tempfile) ? @upload.tempfile.path : @upload.path
    Rails.logger.debug "Source path: #{source_path}"

    processor = ImageProcessing::MiniMagick
      .source(source_path)
      .resize_to_limit(size[0], size[1])
      .convert(OUTPUT_FORMAT)
      .saver(quality: quality)

    processed = processor.call
    Rails.logger.debug "Variant processed, path: #{processed.path}"

    # Force .webp extension by using a dummy .webp filename
    filename = GenerateUniqueFilenameService.call(
      original_filename: "original#{OUTPUT_EXTENSION}",
      suffix: suffix,
      prefix: :avatar
    )

    {
      io: File.open(processed.path),
      filename: filename,
      content_type: OUTPUT_CONTENT_TYPE
    }
  end

  def validate_quality!(quality)
    unless quality.between?(MIN_QUALITY, MAX_QUALITY)
      raise "Quality must be between #{MIN_QUALITY} and #{MAX_QUALITY}"
    end
  end
end
