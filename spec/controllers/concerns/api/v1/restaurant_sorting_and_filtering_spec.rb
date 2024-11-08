require 'rails_helper'

RSpec.describe Api::V1::RestaurantSortingAndFiltering do
  let(:test_class) do
    Class.new do
      include Api::V1::RestaurantSortingAndFiltering
      attr_accessor :params
      
      def initialize(params = {})
        @params = params
      end
    end
  end

  let(:controller) { test_class.new }

  describe '#parse_order_params' do
    context 'with valid parameters' do
      it 'returns the specified order field and direction' do
        controller.params = { order_by: 'name', order_direction: 'asc' }
        field, direction, using_default, message = controller.parse_order_params
        
        expect(field).to eq('name')
        expect(direction).to eq('asc')
        expect(using_default).to be false
        expect(message).to be_nil
      end
    end

    context 'with invalid order field' do
      it 'returns default order field and sets message' do
        controller.params = { order_by: 'invalid_field', order_direction: 'asc' }
        field, direction, using_default, message = controller.parse_order_params
        
        expect(field).to eq('created_at')
        expect(direction).to eq('asc')
        expect(using_default).to be true
        expect(message).to eq('Invalid sorting parameters. Using default sorting.')
      end
    end

    context 'with invalid order direction' do
      it 'returns default direction and sets message' do
        controller.params = { order_by: 'name', order_direction: 'invalid' }
        field, direction, using_default, message = controller.parse_order_params
        
        expect(field).to eq('name')
        expect(direction).to eq('desc')
        expect(using_default).to be true
        expect(message).to eq('Invalid sorting parameters. Using default sorting.')
      end
    end

    context 'with both invalid field and direction' do
      it 'returns default values for both and sets message' do
        controller.params = { order_by: 'invalid', order_direction: 'invalid' }
        field, direction, using_default, message = controller.parse_order_params
        
        expect(field).to eq('created_at')
        expect(direction).to eq('desc')
        expect(using_default).to be true
        expect(message).to eq('Invalid sorting parameters. Using default sorting.')
      end
    end

    context 'with no parameters' do
      it 'returns default values' do
        controller.params = {}
        field, direction, using_default, message = controller.parse_order_params
        
        expect(field).to eq('created_at')
        expect(direction).to eq('desc')
        expect(using_default).to be false
        expect(message).to be_nil
      end
    end
  end

  describe '#apply_filters' do
    let(:scope) { double('scope') }

    context 'with search parameter' do
      before do
        controller.params = { search: 'pizza' }
      end

      it 'applies search filter' do
        expect(scope).to receive(:search_by_full_text).with('pizza').and_return(scope)
        controller.apply_filters(scope)
      end
    end

    context 'with tag parameter' do
      before do
        controller.params = { tag: 'italian' }
      end

      it 'applies tag filter' do
        expect(scope).to receive(:tagged_with).with('italian').and_return(scope)
        controller.apply_filters(scope)
      end
    end

    context 'with both search and tag parameters' do
      before do
        controller.params = { search: 'pizza', tag: 'italian' }
      end

      it 'applies both filters' do
        expect(scope).to receive(:search_by_full_text).with('pizza').and_return(scope)
        expect(scope).to receive(:tagged_with).with('italian').and_return(scope)
        controller.apply_filters(scope)
      end
    end
  end

  describe '#apply_ordering' do
    let(:scope) { double('scope') }

    context 'when ordering by distance' do
      context 'with latitude and longitude' do
        before do
          controller.params = { latitude: '40.7128', longitude: '-74.0060' }
        end

        it 'orders by distance ascending (default)' do
          expect(scope).to receive(:order_by_distance_from).with([40.7128, -74.0060]).and_return(scope)
          controller.apply_ordering(scope, 'distance', 'asc')
        end

        it 'orders by distance descending' do
          expect(scope).to receive(:order_by_distance_from).with([40.7128, -74.0060]).and_return(scope)
          expect(scope).to receive(:reorder).with('distance desc').and_return(scope)
          controller.apply_ordering(scope, 'distance', 'desc')
        end
      end

      context 'without latitude and longitude' do
        before do
          controller.params = {}
        end

        it 'returns scope unchanged' do
          expect(controller.apply_ordering(scope, 'distance', 'asc')).to eq(scope)
        end
      end
    end

    context 'when ordering by created_at' do
      it 'orders by created_at ascending' do
        expect(scope).to receive(:order).with(created_at: 'asc').and_return(scope)
        controller.apply_ordering(scope, 'created_at', 'asc')
      end

      it 'orders by created_at descending' do
        expect(scope).to receive(:order).with(created_at: 'desc').and_return(scope)
        controller.apply_ordering(scope, 'created_at', 'desc')
      end
    end

    context 'when ordering by other fields' do
      it 'orders by name using COALESCE' do
        expected_sql = "LOWER(COALESCE(restaurants.name, google_restaurants.name)) asc, restaurants.id"
        expect(scope).to receive(:order).with(Arel.sql(expected_sql)).and_return(scope)
        controller.apply_ordering(scope, 'name', 'asc')
      end

      it 'orders by rating using COALESCE' do
        expected_sql = "LOWER(COALESCE(restaurants.rating, google_restaurants.rating)) desc, restaurants.id"
        expect(scope).to receive(:order).with(Arel.sql(expected_sql)).and_return(scope)
        controller.apply_ordering(scope, 'rating', 'desc')
      end
    end
  end
end
