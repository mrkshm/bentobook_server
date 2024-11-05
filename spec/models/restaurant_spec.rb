require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:google_restaurant) }
    it { should belong_to(:cuisine_type) }
    it { should have_many(:visits) }
    it { should have_many(:images).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
    it { should validate_numericality_of(:price_level).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(4).allow_nil }
    it { should validate_inclusion_of(:business_status).in_array(['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY']).allow_nil }
  end

  describe 'scopes' do
    describe '.favorites' do
      it 'returns only favorite restaurants' do
        favorite = create(:restaurant, favorite: true)
        not_favorite = create(:restaurant, favorite: false)
        expect(Restaurant.favorites).to include(favorite)
        expect(Restaurant.favorites).not_to include(not_favorite)
      end
    end

    describe '.search_by_full_text' do
      it 'searches restaurants by name and notes' do
        restaurant1 = create(:restaurant, name: 'Pasta Place', notes: 'Great Italian food')
        restaurant2 = create(:restaurant, name: 'Sushi Spot', notes: 'Fresh fish')
        
        expect(Restaurant.search_by_full_text('pasta')).to include(restaurant1)
        expect(Restaurant.search_by_full_text('pasta')).not_to include(restaurant2)
        expect(Restaurant.search_by_full_text('fish')).to include(restaurant2)
        expect(Restaurant.search_by_full_text('fish')).not_to include(restaurant1)
      end
    end

    describe '.search_by_name_and_address' do
      it 'searches restaurants by name and address' do
        restaurant1 = create(:restaurant, name: 'Pasta Place', google_restaurant: create(:google_restaurant, address: '123 Main St'))
        restaurant2 = create(:restaurant, name: 'Sushi Spot', google_restaurant: create(:google_restaurant, address: '456 Elm St'))

        expect(Restaurant.search_by_name_and_address('Pasta')).to include(restaurant1)
        expect(Restaurant.search_by_name_and_address('Pasta')).not_to include(restaurant2)
        expect(Restaurant.search_by_name_and_address('Main')).to include(restaurant1)
        expect(Restaurant.search_by_name_and_address('Main')).not_to include(restaurant2)
      end
    end

    describe '.near' do
      it 'finds restaurants near a given location' do
        near_restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 40.7128, longitude: -74.0060))
        far_restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 34.0522, longitude: -118.2437))

        near_results = Restaurant.near(40.7128, -74.0060, 10000)
        
        expect(near_results).to include(near_restaurant)
        expect(near_results).not_to include(far_restaurant)
      end

      it 'accepts a custom distance' do
        restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 40.7128, longitude: -74.0060))
        
        results = Restaurant.near(40.7128, -74.0060, 50000)
        
        expect(results).to include(restaurant)
      end
    end

    describe '.order_by_distance_from' do
      it 'orders restaurants by distance from a given location' do
        closer_restaurant = create(:restaurant,
          google_restaurant: create(:google_restaurant, 
            name: "Closer Restaurant",
            latitude: 40.7128, 
            longitude: -74.0060
          )
        )
        farther_restaurant = create(:restaurant,
          google_restaurant: create(:google_restaurant, 
            name: "Farther Restaurant",
            latitude: 40.7489, 
            longitude: -73.9680
          )
        )

        ordered_results = Restaurant.order_by_distance_from(40.7300, -74.0000).to_a

        expect(ordered_results.size).to eq(2)
        expect(ordered_results.first.combined_name).to eq("Closer Restaurant")
        expect(ordered_results.last.combined_name).to eq("Farther Restaurant")
      end
    end

    describe '.order_by_visits' do
      it 'orders restaurants by visit count in descending order by default' do
        restaurant_many = create(:restaurant)
        create_list(:visit, 3, restaurant: restaurant_many)
        
        restaurant_few = create(:restaurant)
        create_list(:visit, 1, restaurant: restaurant_few)
        
        restaurant_none = create(:restaurant)

        ordered = Restaurant.order_by_visits.to_a

        expect(ordered.map(&:visit_count)).to eq([3, 1, 0])
        expect(ordered).to eq([restaurant_many, restaurant_few, restaurant_none])
      end

      it 'can order restaurants by visit count in ascending order' do
        restaurant_many = create(:restaurant)
        create_list(:visit, 3, restaurant: restaurant_many)
        
        restaurant_few = create(:restaurant)
        create_list(:visit, 1, restaurant: restaurant_few)
        
        restaurant_none = create(:restaurant)

        ordered = Restaurant.order_by_visits(:asc).to_a

        expect(ordered.map(&:visit_count)).to eq([0, 1, 3])
        expect(ordered).to eq([restaurant_none, restaurant_few, restaurant_many])
      end

      it 'includes restaurants with no visits' do
        restaurant_with_visits = create(:restaurant)
        create_list(:visit, 2, restaurant: restaurant_with_visits)
        
        restaurant_no_visits = create(:restaurant)

        ordered = Restaurant.order_by_visits.to_a

        expect(ordered).to include(restaurant_no_visits)
        expect(ordered.map(&:visit_count)).to eq([2, 0])
      end
    end
  end

  describe 'delegated methods' do
    it 'delegates latitude and longitude to google_restaurant' do
      google_restaurant = create(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
      restaurant = create(:restaurant, google_restaurant: google_restaurant)
      expect(restaurant.latitude).to eq(40.7128)
      expect(restaurant.longitude).to eq(-74.0060)
    end
  end

  describe 'custom methods' do
    describe '#combined_attributes' do
      it 'returns restaurant attribute if present, otherwise google_restaurant attribute' do
        google_restaurant = create(:google_restaurant, name: 'Google Name', address: 'Google Address')
        restaurant = create(:restaurant, google_restaurant: google_restaurant, name: 'Restaurant Name', address: nil)
        
        expect(restaurant.combined_name).to eq('Restaurant Name')
        expect(restaurant.combined_address).to eq('Google Address')
      end

      it 'returns restaurant attribute when both restaurant and google_restaurant have the attribute' do
        google_restaurant = create(:google_restaurant, name: 'Google Name', address: 'Google Address')
        restaurant = create(:restaurant, google_restaurant: google_restaurant, name: 'Restaurant Name', address: 'Restaurant Address')
        
        expect(restaurant.combined_name).to eq('Restaurant Name')
        expect(restaurant.combined_address).to eq('Restaurant Address')
      end
    end

    describe '#visit_count' do
      it 'returns the number of visits for the restaurant' do
        restaurant = create(:restaurant)
        create_list(:visit, 3, restaurant: restaurant)
        
        expect(restaurant.visit_count).to eq(3)
      end
    end

    describe '#parsed_opening_hours' do
      it 'returns parsed JSON of opening hours if present' do
        restaurant = create(:restaurant, opening_hours: '{"Monday": "9AM-5PM"}')
        expect(restaurant.parsed_opening_hours).to eq({"Monday" => "9AM-5PM"})
      end

      it 'returns nil if opening hours are not present' do
        restaurant = create(:restaurant, opening_hours: nil)
        expect(restaurant.parsed_opening_hours).to be_nil
      end

      it 'returns nil if opening hours are invalid JSON' do
        restaurant = create(:restaurant, opening_hours: 'invalid json')
        expect(restaurant.parsed_opening_hours).to be_nil
      end
    end

    describe '#distance_to' do
      it 'calculates distance to given coordinates' do
        nyc_lat, nyc_lon = 40.7128, -74.0060
        dc_lat, dc_lon = 38.9072, -77.0369

        google_restaurant = create(:google_restaurant, latitude: nyc_lat, longitude: nyc_lon)
        restaurant = create(:restaurant, google_restaurant: google_restaurant)
        
        distance = restaurant.distance_to(dc_lat, dc_lon)
        
        # PostGIS returns distance in meters
        expect(distance).to be_within(1000).of(328000) # ~328km between NYC and DC
      end

      it 'returns nil if restaurant coordinates are not set' do
        google_restaurant = create(:google_restaurant)
        google_restaurant.update_columns(
          latitude: nil,
          longitude: nil,
          location: nil
        )
        restaurant = create(:restaurant, google_restaurant: google_restaurant)
        
        expect(restaurant.distance_to(40.7489, -73.9680)).to be_nil
      end
    end

    describe '#price_level_display' do
      it 'returns dollar signs based on price level' do
        restaurant = create(:restaurant, price_level: 3)
        expect(restaurant.price_level_display).to eq('$$$')
      end

      it 'returns nil if price level is not set' do
        restaurant = create(:restaurant, price_level: nil)
        expect(restaurant.price_level_display).to be_nil
      end
    end
  end

  describe '.with_google' do
    it 'includes all combined attributes' do
      google_restaurant = create(:google_restaurant, 
        name: 'Google Name', 
        address: 'Google Address', 
        street: 'Google Street', 
        street_number: '123', 
        city: 'Google City', 
        state: 'GS', 
        country: 'Google Country', 
        postal_code: '12345', 
        phone_number: '123-456-7890', 
        url: 'http://google.com', 
        business_status: 'OPERATIONAL', 
        latitude: 40.7128, 
        longitude: -74.0060
      )
      restaurant = create(:restaurant, 
        google_restaurant: google_restaurant, 
        name: 'Local Name', 
        address: 'Local Address', 
        price_level: 2, 
        rating: 4
      )

      result = Restaurant.with_google.first
      
      Restaurant::GOOGLE_FALLBACK_ATTRIBUTES.each do |attr|
        expect(result.send("combined_#{attr}")).to eq(restaurant.send("combined_#{attr}"))
      end
      expect(result.restaurant_price_level).to eq(2)
      expect(result.restaurant_rating).to eq(4)
    end
  end

  describe 'tagging' do
    it 'can be tagged' do
      restaurant = create(:restaurant)
      restaurant.tag_list.add('italian', 'pizza')
      restaurant.save
      expect(restaurant.tag_list).to contain_exactly('italian', 'pizza')
    end

    it 'can be tagged and untagged' do
      restaurant = create(:restaurant)
      restaurant.tag_list.add('italian', 'pizza')
      restaurant.save
      expect(restaurant.tag_list).to contain_exactly('italian', 'pizza')

      restaurant.tag_list.remove('pizza')
      restaurant.save
      expect(restaurant.tag_list).to contain_exactly('italian')
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for google_restaurant' do
      restaurant_attributes = attributes_for(:restaurant).merge(
        google_restaurant_attributes: attributes_for(:google_restaurant)
      )
      restaurant = Restaurant.create(restaurant_attributes)
      expect(restaurant.google_restaurant).to be_present
    end
  end

  describe 'GOOGLE_FALLBACK_ATTRIBUTES' do
    it 'includes all expected attributes' do
      expected_attributes = [
        :name, :address, :street, :street_number, :city, :state, :country,
        :postal_code, :phone_number, :url, :business_status, :latitude, :longitude
      ]
      expect(Restaurant::GOOGLE_FALLBACK_ATTRIBUTES).to match_array(expected_attributes)
    end
  end

  describe '#visit_count' do
    it 'returns the number of visits for the restaurant' do
      restaurant = create(:restaurant)
      create_list(:visit, 3, restaurant: restaurant)
      
      expect(restaurant.visit_count).to eq(3)
    end

    it 'returns 0 when there are no visits' do
      restaurant = create(:restaurant)
      expect(restaurant.visit_count).to eq(0)
    end
  end

  describe '#price_level_display' do
    it 'returns dollar signs based on price level' do
      restaurant = create(:restaurant, price_level: 3)
      expect(restaurant.price_level_display).to eq('$$$')
    end

    it 'returns nil if price level is not set' do
      restaurant = create(:restaurant, price_level: nil)
      expect(restaurant.price_level_display).to be_nil
    end

    it 'returns an empty string for price level 0' do
      restaurant = create(:restaurant, price_level: 0)
      expect(restaurant.price_level_display).to eq('')
    end
  end

  describe '.near' do
    it 'finds restaurants near a given location' do
      near_restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 40.7128, longitude: -74.0060))
      far_restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 34.0522, longitude: -118.2437))

      near_results = Restaurant.near(40.7128, -74.0060, 10000)
      
      expect(near_results).to include(near_restaurant)
      expect(near_results).not_to include(far_restaurant)
    end

    it 'accepts additional options' do
      restaurant = create(:restaurant, google_restaurant: create(:google_restaurant, latitude: 40.7128, longitude: -74.0060))
      
      results = Restaurant.near(40.7128, -74.0060, 10, units: :km)
      
      expect(results).to include(restaurant)
    end
  end

  describe '.order_by_distance_from' do
    it 'orders restaurants by distance from a given location' do
      closer_restaurant = create(:restaurant,
        google_restaurant: create(:google_restaurant, 
          name: "Closer Restaurant",
          latitude: 40.7128, 
          longitude: -74.0060
        )
      )
      farther_restaurant = create(:restaurant,
        google_restaurant: create(:google_restaurant, 
          name: "Farther Restaurant",
          latitude: 40.7489, 
          longitude: -73.9680
        )
      )

      ordered_results = Restaurant.order_by_distance_from(40.7300, -74.0000).to_a

      expect(ordered_results.size).to eq(2)
      expect(ordered_results.first.combined_name).to eq("Closer Restaurant")
      expect(ordered_results.last.combined_name).to eq("Farther Restaurant")
    end
  end

  describe '#parsed_opening_hours' do
    it 'returns parsed JSON of opening hours if present' do
      restaurant = create(:restaurant, opening_hours: '{"Monday": "9AM-5PM"}')
      expect(restaurant.parsed_opening_hours).to eq({"Monday" => "9AM-5PM"})
    end

    it 'returns nil if opening hours are not present' do
      restaurant = create(:restaurant, opening_hours: nil)
      expect(restaurant.parsed_opening_hours).to be_nil
    end

    it 'returns nil if opening hours are invalid JSON' do
      restaurant = create(:restaurant, opening_hours: 'invalid json')
      expect(restaurant.parsed_opening_hours).to be_nil
    end
  end

  describe '#distance_to' do
    it 'calculates distance to given coordinates' do
      nyc_lat, nyc_lon = 40.7128, -74.0060
      dc_lat, dc_lon = 38.9072, -77.0369

      google_restaurant = create(:google_restaurant, latitude: nyc_lat, longitude: nyc_lon)
      restaurant = create(:restaurant, google_restaurant: google_restaurant)
      
      distance = restaurant.distance_to(dc_lat, dc_lon)
      
      # PostGIS returns distance in meters
      expect(distance).to be_within(1000).of(328000) # ~328km between NYC and DC
    end

    it 'returns nil if restaurant coordinates are not set' do
      google_restaurant = create(:google_restaurant)
      google_restaurant.update_columns(
        latitude: nil,
        longitude: nil,
        location: nil
      )
      restaurant = create(:restaurant, google_restaurant: google_restaurant)
      
      expect(restaurant.distance_to(40.7489, -73.9680)).to be_nil
    end
  end
end
