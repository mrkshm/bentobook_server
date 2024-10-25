require 'rails_helper'
require 'tempfile'

RSpec.describe RestaurantUpdater do
  # Use before(:all) to ensure cuisine type is created only once for all tests
  before(:all) do
    CuisineType.find_or_create_by!(name: "italian")
  end

  after(:all) do
    CuisineType.delete_all
  end

  let(:italian) { CuisineType.find_by!(name: "italian") }
  let(:restaurant) { create(:restaurant, cuisine_type: italian) }
  let(:params) do
    {
      name: "Updated Restaurant",
      address: "456 Update St",
      cuisine_type_name: "italian",
      rating: 5,
      price_level: 3,
      tag_list: "tag1, tag2"
    }
  end
  let(:updater) { RestaurantUpdater.new(restaurant, params) }

  describe "#update" do
    it "updates the restaurant with valid params" do
      expect(updater.update).to be true
      restaurant.reload
      expect(restaurant.name).to eq("Updated Restaurant")
      expect(restaurant.address).to eq("456 Update St")
      expect(restaurant.cuisine_type.name).to eq("italian")
      expect(restaurant.rating).to eq(5)
      expect(restaurant.price_level).to eq(3)
      expect(restaurant.tag_list).to contain_exactly("tag1", "tag2")
    end

    it "returns false if update fails" do
      allow(restaurant).to receive(:save).and_return(false)
      expect(updater.update).to be false
    end

    it "returns false when no changes are made" do
      restaurant = create(:restaurant, 
        name: "Existing Restaurant", 
        address: "123 Existing St",
        cuisine_type: italian,
        rating: 5,
        price_level: 3
      )
      
      params = { 
        name: "Existing Restaurant",
        address: "123 Existing St",
        cuisine_type_name: "italian",
        rating: 5,
        price_level: 3
      }
      updater = RestaurantUpdater.new(restaurant, params)

      expect(updater.update).to be false
    end

    context "when an error occurs during update" do
      let(:error_message) { "Something went wrong" }
      
      before do
        allow(restaurant).to receive(:save).and_raise(StandardError.new(error_message))
      end

      it "adds the error message and returns false" do
        expect(updater.update).to be false
        expect(restaurant.errors[:base]).to include(error_message)
      end
    end
  end

  describe "#update_cuisine_type" do
    context "when cuisine_type_name is provided" do
      let(:params) { { cuisine_type_name: "italian" } }
      let!(:temp_cuisine_type) { create(:cuisine_type, name: "temporary") }
      let(:restaurant_for_cuisine_test) { create(:restaurant, cuisine_type: temp_cuisine_type) }
      let(:updater_for_cuisine_test) { RestaurantUpdater.new(restaurant_for_cuisine_test, params) }

      after(:each) do
        # First update all restaurants to use italian cuisine type
        Restaurant.where(cuisine_type: temp_cuisine_type).update_all(cuisine_type_id: italian.id)
        # Then delete temporary cuisine types
        CuisineType.where.not(name: "italian").delete_all
      end

      it "uses an existing cuisine type" do
        expect {
          updater_for_cuisine_test.send(:update_cuisine_type)
        }.not_to change(CuisineType, :count)
        
        restaurant_for_cuisine_test.reload
        expect(restaurant_for_cuisine_test.cuisine_type).to eq(italian)
      end

      it "raises RecordNotFound when cuisine type doesn't exist" do
        invalid_params = { cuisine_type_name: "nonexistent_cuisine" }
        invalid_updater = RestaurantUpdater.new(restaurant_for_cuisine_test, invalid_params)

        expect {
          invalid_updater.send(:update_cuisine_type)
        }.to raise_error(ActiveRecord::RecordNotFound, "Cuisine type 'nonexistent_cuisine' is not valid")
      end
    end
  end

  describe "#update_images" do
    it "adds new images to the restaurant" do
      temp_file = Tempfile.new(['test_image', '.jpg'])
      temp_file.write('dummy image content')
      temp_file.rewind

      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: 'test_image.jpg',
        type: 'image/jpeg'
      )

      params[:images] = [uploaded_file]
      expect {
        updater.send(:update_images)
      }.to change(restaurant.images, :count).by(1)

      temp_file.close
      temp_file.unlink
    end

    context "when image fails to save" do
      let(:error_messages) { ["File can't be blank"] }
      
      before do
        temp_file = Tempfile.new(['test_image', '.jpg'])
        temp_file.write('dummy image content')
        temp_file.rewind

        uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: temp_file,
          filename: 'test_image.jpg',
          type: 'image/jpeg'
        )

        params[:images] = [uploaded_file]
        
        # Create a real Image instance instead of a double
        invalid_image = Image.new
        invalid_image.errors.add(:file, "can't be blank")
        
        # Mock the build behavior to return our invalid image
        allow(restaurant.images).to receive(:build).and_return(invalid_image)
        allow(invalid_image).to receive(:save).and_return(false)
      end

      it "logs error and raises RecordInvalid" do
        expect(Rails.logger).to receive(:error).with("Failed to save image: #{error_messages}")
        expect { updater.send(:update_images) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
