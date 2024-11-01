require 'securerandom'

class ImageHandlingService
  DEFAULT_COMPRESSION_OPTIONS = {
    resize_to_limit: [1200, 1200],
    format: :jpg,
    saver: { 
      quality: 73,
      strip: true
    }
  }

  def self.process_images(imageable, params, compress: false)
    if avatar_present?(params)
      image = get_avatar_from_params(params)
      process_single_attachment(imageable, image, :avatar, compress)
      { success: true }
    else
      { success: false, message: "No image params" }
    end
  end

  private

  def self.avatar_present?(params)
    (params[:contact] && params[:contact][:avatar].present?) ||
    (params[:profile] && params[:profile][:avatar].present?)
  end

  def self.get_avatar_from_params(params)
    params[:contact]&.[](:avatar) || params[:profile]&.[](:avatar)
  end

  def self.process_single_attachment(imageable, image, attachment_name, compress)
    if imageable.send(attachment_name).attached?
      imageable.send(attachment_name).purge
    end

    if compress
      processed_blob = compress_image(image)
      imageable.send(attachment_name).attach(processed_blob)
    else
      imageable.send(attachment_name).attach(image)
    end
  end

  def self.compress_image(image)
    temp_blob = ActiveStorage::Blob.create_and_upload!(
      io: image.tempfile,
      filename: image.original_filename,
      content_type: image.content_type
    )

    variant = temp_blob.variant(DEFAULT_COMPRESSION_OPTIONS).processed

    compressed_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(variant.download),
      filename: "#{File.basename(image.original_filename, '.*')}.jpg",
      content_type: 'image/jpeg'
    )

    temp_blob.purge

    compressed_blob
  end
end
