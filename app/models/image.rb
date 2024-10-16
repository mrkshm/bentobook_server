class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates :imageable, presence: true
  validates :file, presence: true

  has_one_attached :file

  after_create :set_filename
  before_destroy :purge_file

  private

  def set_filename
    return unless file.attached?

    original_filename = file.blob.filename.to_s
    extension = File.extname(original_filename).downcase
    basename = File.basename(original_filename, extension)
    truncated_name = basename.truncate(12, omission: '')
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    new_filename = "#{timestamp}_#{truncated_name}#{extension}"

    # Update both filename and key
    file.blob.update(filename: new_filename)
    file.blob.update(key: new_filename)
  end

  def purge_file
  file.purge if file.attached?
end

end
