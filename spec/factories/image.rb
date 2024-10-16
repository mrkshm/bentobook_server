FactoryBot.define do
    factory :image do
      association :imageable, factory: :restaurant
  
      after(:build) do |image|
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpeg')
      end
    end
end