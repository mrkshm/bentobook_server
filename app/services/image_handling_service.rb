require 'securerandom'

class ImageHandlingService
  def self.process_images(visit, image_params)
    return { success: false, message: "No image params" } unless image_params && image_params[:images]

    results = []
    image_params[:images].each do |image|
      if image.respond_to?(:tempfile) && image.respond_to?(:original_filename)
        new_image = visit.images.new
        new_image.file.attach(
          io: image.tempfile,
          filename: image.original_filename,
          content_type: image.content_type
        )
        if new_image.save
          Rails.logger.info "Image created successfully: #{new_image.id}"
          results << { success: true, image_id: new_image.id }
        else
          error_message = "Failed to create image: #{new_image.errors.full_messages.join(', ')}"
          Rails.logger.error error_message
          results << { success: false, error: error_message }
        end
      else
        Rails.logger.warn "Skipping non-file object in images array: #{image.class}"
        results << { success: false, error: "Invalid file object: #{image.class}" }
      end
    end

    visit.save!
    { success: true, results: results }
  rescue StandardError => e
    Rails.logger.error "Error in process_images: #{e.message}"
    { success: false, error: e.message }
  end
end
