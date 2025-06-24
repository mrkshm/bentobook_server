# == Schema Information
#
# Table name: images
#
#  id             :bigint           not null, primary key
#  description    :text
#  imageable_type :string           not null
#  is_cover       :boolean
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  imageable_id   :bigint           not null
#
# Indexes
#
#  index_images_on_imageable  (imageable_type,imageable_id)
#
class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates :file, presence: true

  has_one_attached :file

  after_create :set_filename
  before_destroy :purge_file
  after_commit :process_file_variants, if: -> { saved_change_to_attribute?("file_id") }

  private

  def set_filename
    return unless file.attached?

    begin
      original_filename = file.blob.filename.to_s
      extension = File.extname(original_filename).downcase
      basename = File.basename(original_filename, extension)

      # Create SEO-friendly base name
      sanitized_name = basename
        .unicode_normalize(:nfkd)
        .encode("ASCII", replace: "")
        .downcase
        .gsub(/[^a-z0-9\-_]+/, "-")
        .gsub(/-{2,}/, "-")
        .truncate(50, omission: "")
        .gsub(/\A-|-\z/, "")

      # Generate unique filename
      unique_suffix = SecureRandom.hex(4)  # 8 characters, sufficient for uniqueness
      new_filename = "#{sanitized_name}-#{unique_suffix}#{extension}"

      # Update blob directly without copying
      file.blob.update!(filename: new_filename)
    rescue StandardError => e
      Rails.logger.error "Error in set_filename: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end

    true
  end

  def purge_file
    file.purge if file.attached?
  rescue => e
    Rails.logger.error "Error purging file: #{e.message}"
  end
end
