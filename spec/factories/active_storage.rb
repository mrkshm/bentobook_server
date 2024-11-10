FactoryBot.define do
  factory :active_storage_blob, class: 'ActiveStorage::Blob' do
    filename { 'test.jpg' }
    content_type { 'image/jpeg' }
    byte_size { 1024 }
    checksum { SecureRandom.hex(32) }
    key { SecureRandom.uuid }
  end

  factory :active_storage_attachment, class: 'ActiveStorage::Attachment' do
    name { 'file' }
    record_type { 'Image' }
    record_id { 1 }
    association :blob, factory: :active_storage_blob
  end
end
