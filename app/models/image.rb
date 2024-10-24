class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates :file, presence: true

  has_one_attached :file

  after_create :set_filename
  before_destroy :purge_file

  private

  def set_filename
    return unless file.attached?

    begin
      original_filename = file.blob.filename.to_s
      extension = File.extname(original_filename).downcase
      basename = File.basename(original_filename, extension)
      truncated_name = basename.truncate(12, omission: '')
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      new_filename = "#{timestamp}_#{truncated_name}#{extension}"

      # Store the original key before updating
      original_key = file.blob.key

      # Update the blob attributes
      file.blob.update!(
        filename: new_filename,
        key: new_filename
      )

      # Verify the file exists in storage
      unless file.blob.service.exist?(file.blob.key)
        Rails.logger.error "File not found in storage after rename: #{file.blob.key}"
        # Try to copy from original key if it exists
        if file.blob.service.exist?(original_key)
          file.blob.service.copy(original_key, file.blob.key)
        end
      end
    rescue => e
      Rails.logger.error "Error in set_filename: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  def purge_file
    file.purge if file.attached?
  rescue => e
    Rails.logger.error "Error purging file: #{e.message}"
  end
end
