require 'rails_helper'
require 'tempfile'

RSpec.describe RestaurantUpdater do
  let(:restaurant) { create(:restaurant) }
  let(:params) do
    {
      name: "Updated Restaurant",
      address: "456 Update St",
      cuisine_type_name: "Italian",
      rating: 5,
      price_level: 3,
      tag_list: "tag1, tag2"
    }
  end
  let(:updater) { RestaurantUpdater.new(restaurant, params) }

  before(:each) do
    CuisineType.destroy_all
  end

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
      restaurant = create(:restaurant, name: "Existing Restaurant", address: "123 Existing St")
      params = { name: "Existing Restaurant", address: "123 Existing St" }
      updater = RestaurantUpdater.new(restaurant, params)

      expect(Rails.logger).to receive(:info).with("Starting update for restaurant #{restaurant.id}")
      expect(Rails.logger).to receive(:info).with("Changes made: false")
      expect(Rails.logger).to receive(:info).with("No changes detected for restaurant #{restaurant.id}")

      expect(updater.update).to be false
    end
  end

  describe "#update_comparable_attributes" do
    it "updates comparable attributes" do
      updater.send(:update_comparable_attributes)
      expect(restaurant.name).to eq("Updated Restaurant")
      expect(restaurant.address).to eq("456 Update St")
    end
  end

  describe "#update_cuisine_type" do
    let(:temp_cuisine_type) { create(:cuisine_type, name: "Temporary") }
    let(:restaurant_for_cuisine_test) { create(:restaurant, cuisine_type: temp_cuisine_type) }
    let(:updater_for_cuisine_test) { RestaurantUpdater.new(restaurant_for_cuisine_test, params) }

    before(:each) do
      CuisineType.destroy_all
      restaurant_for_cuisine_test.update_column(:cuisine_type_id, nil)
    end

    context "when cuisine_type_name is provided" do
      let(:params) { { cuisine_type_name: "Italian" } }

      it "creates a new cuisine type if it doesn't exist" do
        expect {
          result = updater_for_cuisine_test.send(:update_cuisine_type)
          puts "Test 1: CuisineType count: #{CuisineType.count}, Result: #{result}"
          expect(result).to be true
        }.to change(CuisineType, :count).by(1)
        restaurant_for_cuisine_test.reload
        expect(restaurant_for_cuisine_test.cuisine_type).not_to be_nil
        expect(restaurant_for_cuisine_test.cuisine_type.name).to eq("italian")
      end

      it "uses an existing cuisine type if it exists" do
        create(:cuisine_type, name: "italian")
        expect {
          result = updater_for_cuisine_test.send(:update_cuisine_type)
          puts "Test 2: CuisineType count: #{CuisineType.count}, Result: #{result}"
          expect(result).to be true
        }.not_to change(CuisineType, :count)
        restaurant_for_cuisine_test.reload
        expect(restaurant_for_cuisine_test.cuisine_type).not_to be_nil
        expect(restaurant_for_cuisine_test.cuisine_type.name).to eq("italian")
      end

      it "returns false if the restaurant already has the cuisine type" do
        cuisine_type = create(:cuisine_type, name: "italian")
        restaurant_for_cuisine_test.update!(cuisine_type: cuisine_type)
        result = updater_for_cuisine_test.send(:update_cuisine_type)
        puts "Test 3: CuisineType count: #{CuisineType.count}, Result: #{result}"
        expect(result).to be false
      end

      it "is case insensitive" do
        create(:cuisine_type, name: "italian")
        params[:cuisine_type_name] = "ITALIAN"
        expect {
          result = updater_for_cuisine_test.send(:update_cuisine_type)
          puts "Test 4: CuisineType count: #{CuisineType.count}, Result: #{result}"
          expect(result).to be true
        }.not_to change(CuisineType, :count)
        restaurant_for_cuisine_test.reload
        expect(restaurant_for_cuisine_test.cuisine_type).not_to be_nil
        expect(restaurant_for_cuisine_test.cuisine_type.name).to eq("italian")
      end
    end

    context "when cuisine_type_id is provided" do
      let(:cuisine_type) { create(:cuisine_type) }
      let(:params) { { cuisine_type_id: cuisine_type.id } }

      it "updates the cuisine type" do
        expect(updater.send(:update_cuisine_type)).to be true
        expect(restaurant.cuisine_type).to eq(cuisine_type)
      end

      it "returns false if the restaurant already has the cuisine type" do
        restaurant.update(cuisine_type: cuisine_type)
        expect(updater.send(:update_cuisine_type)).to be false
      end
    end
  end

  describe "#update_non_comparable_attributes" do
    it "updates non-comparable attributes" do
      updater.send(:update_non_comparable_attributes)
      expect(restaurant.rating).to eq(5)
      expect(restaurant.price_level).to eq(3)
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
  end
end
