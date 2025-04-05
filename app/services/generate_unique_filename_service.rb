# frozen_string_literal: true

class GenerateUniqueFilenameService
  class Error < StandardError; end
  class ValidationError < Error; end

  VALID_SUFFIXES = %i[thumb sm md lg original].freeze
  VALID_PREFIXES = %i[avatar contact restaurant visit].freeze
  VALID_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp].freeze
  DEFAULT_SIZE = 12
  FILENAME_PARTS = [].freeze

  class << self
    def call(original_filename:, suffix: nil, prefix: nil, size: DEFAULT_SIZE)
      new(original_filename:, suffix:, prefix:, size:).generate
    end
  end

  def initialize(original_filename:, suffix: nil, prefix: nil, size: DEFAULT_SIZE)
    @original_filename = original_filename.to_s
    @suffix = suffix
    @prefix = prefix
    @size = size
    validate_inputs!
  end

  def generate
    # Get the original extension if any
    extension = File.extname(@original_filename).downcase
    extension = ".webp" if extension.empty? # Default to .webp if no extension

    # Generate a unique identifier
    unique_id = SecureRandom.alphanumeric(@size)

    # Build the filename
    filename = FILENAME_PARTS.dup
    filename << @prefix if @prefix && VALID_PREFIXES.include?(@prefix)
    filename << unique_id
    filename << @suffix.to_s if @suffix && VALID_SUFFIXES.include?(@suffix)

    # Join with underscores and add extension
    result = filename.join("_")
    result << extension

    result
  end

  private

  def validate_inputs!
    raise ValidationError, "Original filename cannot be blank" if @original_filename.blank?
    raise ValidationError, "Size must be positive" unless @size.positive?
    raise ValidationError, "Invalid suffix: #{@suffix}" if @suffix && !VALID_SUFFIXES.include?(@suffix)
    raise ValidationError, "Invalid prefix: #{@prefix}" if @prefix && !VALID_PREFIXES.include?(@prefix)

    extension = File.extname(@original_filename).downcase
    if !extension.empty? && !VALID_EXTENSIONS.include?(extension)
      raise ValidationError, "Invalid file extension: #{extension}"
    end
  end
end
