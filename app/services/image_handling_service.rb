require "securerandom"

class ImageHandlingService
  DEFAULT_COMPRESSION_OPTIONS = {
    resize_to_limit: [ 1200, 1200 ],
    format: :webp,  # Changed from :jpg
    saver: {
      quality: 80,  # WebP can use slightly higher quality for same file size
      strip: true,
      effort: 4     # WebP-specific compression effort (0-6)
    }
  }

  def self.process_images(imageable, params, compress: false)
    Rails.logger.info "ImageHandlingService#process_images called with params: #{params.inspect}"
    if avatar_present?(params)
      Rails.logger.info "Avatar is present in params"
      image = get_avatar_from_params(params)
      Rails.logger.info "Retrieved avatar: #{image.inspect}"
      process_single_attachment(imageable, image, :avatar, compress)
      { success: true }
    else
      Rails.logger.info "No avatar found in params"
      { success: false, message: "No image params" }
    end
  rescue => e
    Rails.logger.error "Error in ImageHandlingService#process_images: #{e.class.name}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  private

  def self.avatar_present?(params)
    [ :contact, :profile ].any? do |key|
      params[key]&.[](:avatar)&.present? || params.dig(key, :avatar)&.present?
    end
  end

  def self.get_avatar_from_params(params)
    [ :contact, :profile ].map do |key|
      params[key]&.[](:avatar) || params.dig(key, :avatar)
    end.compact.first
  end

  def self.process_single_attachment(imageable, image, attachment_name, compress)
    if imageable.send(attachment_name).attached?
      imageable.send(attachment_name).purge
    end

    # Generate standardized filename
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    entity_type = imageable.class.name.downcase
    entity_id = imageable.id || "new"
    extension = compress ? ".webp" : File.extname(image.original_filename)
    new_filename = "#{attachment_name}_#{entity_type}_#{entity_id}_#{timestamp}#{extension}"

    if compress
      processed_blob = compress_image(image, new_filename)
      imageable.send(attachment_name).attach(processed_blob)
    else
      # For uncompressed files, attach with new filename
      blob = ActiveStorage::Blob.create_and_upload!(
        io: image,
        filename: new_filename,
        content_type: image.content_type
      )
      imageable.send(attachment_name).attach(blob)
    end
  end

  def self.compress_image(image, new_filename)
    Rails.logger.info "Compressing image: #{image.inspect}"

    # Read the file content into memory once
    file_content = image.read

    # Create an in-memory temp file for image processing
    temp_file = Tempfile.new([ "avatar", File.extname(image.original_filename) ])
    temp_file.binmode
    temp_file.write(file_content)
    temp_file.rewind

    # Process the image using ImageProcessing directly
    processed_file = ImageProcessing::Vips.source(temp_file.path)
      .resize_to_limit(1200, 1200)
      .saver(quality: 80, strip: true, effort: 4)
      .convert("webp")
      .call

    # Create blob manually to avoid double checksum
    service = ActiveStorage::Blob.service
    key = SecureRandom.base58(24)
    checksum = Digest::MD5.file(processed_file.path).base64digest

    blob = ActiveStorage::Blob.create!(
      key: key,
      filename: new_filename,
      byte_size: File.size(processed_file.path),
      checksum: checksum,
      content_type: "image/webp",  # Updated content type
      service_name: service.name
    )

    # Upload the file separately
    service.upload(
      key,
      processed_file,
      content_type: "image/webp"  # Updated content type
    )

    # Clean up temporary files
    temp_file.close
    temp_file.unlink
    File.unlink(processed_file.path) if File.exist?(processed_file.path)

    blob
  end
end
