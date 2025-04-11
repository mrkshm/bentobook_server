# Cuisine Type Categorization Implementation Plan

This document outlines the detailed plan to transition from the current flat cuisine type structure to a hierarchical categorization system.

## Current System Overview

The current system uses a flat list of cuisine types without any categorization:
- `CuisineType` model with a simple name field
- Direct association between restaurants and cuisine types
- Validation through the `CuisineTypeValidation` concern
- Seeds file with a flat list of cuisine types

## Target System Overview

The new system will organize cuisine types into categories as follows:

```json
{
  "categories": [
    {
      "name": "African",
      "cuisine_types": [
        "African",
        "Ethiopian",
        "Eritrean",
        "Senegalese",
        "Moroccan",
        "South African",
        "African Fusion"
      ]
    },
    {
      "name": "Asian",
      "cuisine_types": [
        "Asian",
        "Chinese",
        "Japanese",
        "Korean",
        "Thai",
        "Vietnamese",
        "Indian",
        "Taiwanese",
        "Asian Fusion"
      ]
    },
    {
      "name": "European",
      "cuisine_types": [
        "European",
        "French",
        "Italian",
        "Spanish",
        "Greek",
        "German",
        "Polish",
        "Hungarian",
        "Russian",
        "Austrian",
        "Swiss",
        "British",
        "Portuguese",
        "Mediterranean",
        "Scandinavian",
        "European Fusion"
      ]
    },
    {
      "name": "American",
      "cuisine_types": [
        "American",
        "US",
        "Southern",
        "BBQ",
        "Soul Food",
        "Mexican",
        "Brazilian",
        "Peruvian",
        "Cajun",
        "American Fusion"
      ]
    },
    {
      "name": "Middle Eastern",
      "cuisine_types": [
        "Middle Eastern",
        "Lebanese",
        "Turkish",
        "Israeli",
        "Persian",
        "Arabic",
        "Middle Eastern Fusion"
      ]
    },
    {
      "name": "Special",
      "cuisine_types": [
        "Special",
        "Vegetarian",
        "Vegan",
        "Keto",
        "Paleo",
        "Gluten-Free",
        "Special Fusion"
      ]
    },
    {
      "name": "Dining Type",
      "cuisine_types": [
        "Dining Type",
        "Cafe",
        "Wine Bar",
        "Pub",
        "Brewery",
        "Fast Food",
        "Dining Fusion"
      ]
    },
    {
      "name": "Other",
      "cuisine_types": [
        "Other"
      ]
    }
  ]
}

## Phase 1: Database Changes

### 1.1 Create Category Model

**Task:** Generate a new Category model

**Implementation:**
```ruby
# Terminal command
rails generate model Category name:string display_order:integer

# In the migration file
class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :display_order, default: 0

      t.timestamps
    end
    add_index :categories, :name, unique: true
    add_index :categories, :display_order
  end
end
```

### 1.2 Update CuisineType Model

**Task:** Add category reference and display order to CuisineType

**Implementation:**
```ruby
# Terminal command
rails generate migration AddCategoryToCuisineTypes category:references display_order:integer

# In the migration file
class AddCategoryToCuisineTypes < ActiveRecord::Migration[7.0]
  def change
    add_reference :cuisine_types, :category, foreign_key: true
    add_column :cuisine_types, :display_order, :integer, default: 0
    add_index :cuisine_types, :display_order
  end
end
```

### 1.3 Data Migration

**Task:** Create a migration to populate categories and assign cuisine types

**Implementation:**
```ruby
# Terminal command
rails generate migration PopulateCategoriesAndAssignCuisineTypes

# In the migration file
class PopulateCategoriesAndAssignCuisineTypes < ActiveRecord::Migration[7.0]
  def up
    # First, clear out all existing cuisine types that aren't associated with restaurants
    CuisineType.includes(:restaurants).where(restaurants: { id: nil }).destroy_all
    puts "Removed unused cuisine types"
    
    categories = [
      { name: "African", display_order: 1 },
      { name: "Asian", display_order: 2 },
      { name: "European", display_order: 3 },
      { name: "American", display_order: 4 },
      { name: "Middle Eastern", display_order: 5 },
      { name: "Special", display_order: 6 },
      { name: "Dining Type", display_order: 7 },
      { name: "Other", display_order: 8 }
    ]

    ActiveRecord::Base.transaction do
      categories.each do |category_data|
        Category.find_or_create_by!(name: category_data[:name]) do |category|
          category.display_order = category_data[:display_order]
        end
      end
      
      puts "Created #{Category.count} categories"
      
      cuisine_types_by_category = {
        "African" => [
          { name: "african", display_order: 1 },
          { name: "ethiopian", display_order: 2 },
          { name: "eritrean", display_order: 3 },
          { name: "senegalese", display_order: 4 },
          { name: "moroccan", display_order: 5 },
          { name: "south_african", display_order: 6 },
          { name: "african_fusion", display_order: 7 }
        ],
        "Asian" => [
          { name: "asian", display_order: 1 },
          { name: "chinese", display_order: 2 },
          { name: "japanese", display_order: 3 },
          { name: "korean", display_order: 4 },
          { name: "thai", display_order: 5 },
          { name: "vietnamese", display_order: 6 },
          { name: "indian", display_order: 7 },
          { name: "taiwanese", display_order: 8 },
          { name: "asian_fusion", display_order: 9 }
        ],
        "European" => [
          { name: "european", display_order: 1 },
          { name: "french", display_order: 2 },
          { name: "italian", display_order: 3 },
          { name: "spanish", display_order: 4 },
          { name: "greek", display_order: 5 },
          { name: "german", display_order: 6 },
          { name: "polish", display_order: 7 },
          { name: "hungarian", display_order: 8 },
          { name: "russian", display_order: 9 },
          { name: "austrian", display_order: 10 },
          { name: "swiss", display_order: 11 },
          { name: "british", display_order: 12 },
          { name: "portuguese", display_order: 13 },
          { name: "mediterranean", display_order: 14 },
          { name: "scandinavian", display_order: 15 },
          { name: "european_fusion", display_order: 16 }
        ],
        "American" => [
          { name: "american", display_order: 1 },
          { name: "us", display_order: 2 },
          { name: "southern", display_order: 3 },
          { name: "bbq", display_order: 4 },
          { name: "soul_food", display_order: 5 },
          { name: "mexican", display_order: 6 },
          { name: "brazilian", display_order: 7 },
          { name: "peruvian", display_order: 8 },
          { name: "cajun", display_order: 9 },
          { name: "american_fusion", display_order: 10 }
        ],
        "Middle Eastern" => [
          { name: "middle_eastern", display_order: 1 },
          { name: "lebanese", display_order: 2 },
          { name: "turkish", display_order: 3 },
          { name: "israeli", display_order: 4 },
          { name: "persian", display_order: 5 },
          { name: "arabic", display_order: 6 },
          { name: "middle_eastern_fusion", display_order: 7 }
        ],
        "Special" => [
          { name: "special", display_order: 1 },
          { name: "vegetarian", display_order: 2 },
          { name: "vegan", display_order: 3 },
          { name: "keto", display_order: 4 },
          { name: "paleo", display_order: 5 },
          { name: "gluten_free", display_order: 6 },
          { name: "special_fusion", display_order: 7 }
        ],
        "Dining Type" => [
          { name: "dining_type", display_order: 1 },
          { name: "cafe", display_order: 2 },
          { name: "wine_bar", display_order: 3 },
          { name: "pub", display_order: 4 },
          { name: "brewery", display_order: 5 },
          { name: "fast_food", display_order: 6 },
          { name: "dining_fusion", display_order: 7 }
        ],
        "Other" => [
          { name: "other", display_order: 1 }
        ]
      }

      cuisine_types_by_category.each do |category_name, cuisine_types|
        category = Category.find_by!(name: category_name)
        
        cuisine_types.each do |cuisine_type_data|
          CuisineType.find_or_create_by!(name: cuisine_type_data[:name]) do |cuisine_type|
            cuisine_type.category = category
            cuisine_type.display_order = cuisine_type_data[:display_order]
          end
        end
      end
      
      puts "Created #{CuisineType.count} cuisine types"
      
      # Get the "Other" cuisine type
      other_cuisine = CuisineType.find_by!(name: "other")
      
      # Update existing restaurants without a cuisine type
      restaurants_updated = Restaurant.where(cuisine_type_id: nil).update_all(cuisine_type_id: other_cuisine.id)
      
      puts "Updated #{restaurants_updated} restaurants with 'Other' cuisine type"
      
      # Map old cuisine types to new ones
      cuisine_type_mapping = {
        'african' => 'african_fusion',
        'asian' => 'asian_fusion',
        'asian_fusion' => 'asian_fusion',
        'bakery' => 'cafe',
        'bar' => 'pub',
        'brunch' => 'cafe',
        'burger' => 'fast_food',
        'caribbean' => 'american_fusion',
        'dim_sum' => 'chinese',
        'fusion' => 'special_fusion',
        'middle_eastern' => 'middle_eastern_fusion',
        'noodles' => 'asian_fusion',
        'ramen' => 'japanese',
        'seafood' => 'european_fusion',
        'steakhouse' => 'american_fusion',
        'turkish' => 'turkish',
        # Keeping: taiwanese, portuguese, peruvian, mediterranean
      }
      
      # Update restaurants with mapped cuisine types
      cuisine_type_mapping.each do |old_name, new_name|
        old_cuisine = CuisineType.find_by(name: old_name)
        next unless old_cuisine && old_cuisine.restaurants.any?
        
        new_cuisine = CuisineType.find_by(name: new_name)
        if new_cuisine
          count = Restaurant.where(cuisine_type_id: old_cuisine.id).update_all(cuisine_type_id: new_cuisine.id)
          puts "Updated #{count} restaurants from '#{old_name}' to '#{new_name}'"
        end
      end
    end
  end
  
  def down
    # Remove category associations
    CuisineType.update_all(category_id: nil, display_order: 0)
    
    # Remove categories
    Category.destroy_all
  end
end
```

## Phase 2: Model Updates

### 2.1 Update CuisineType Model

**Task:** Update the CuisineType model with category association and new scopes

**Implementation:**
```ruby
# app/models/cuisine_type.rb
class CuisineType < ApplicationRecord
  belongs_to :category, optional: true
  has_many :restaurants

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  
  # Scopes
  scope :alphabetical, -> { all.sort_by { |ct| ct.translated_name.downcase } }
  scope :by_category, -> { includes(:category).order('categories.display_order', :display_order) }
  scope :in_category, ->(category_id) { where(category_id: category_id).order(:display_order) }
  
  def translated_name
    I18n.t("cuisine_types.#{name}", default: name)
  end
  
  # Helper method to get cuisine types grouped by category
  def self.grouped_by_category
    by_category.group_by(&:category)
  end
end
```

### 2.2 Create Category Model

**Task:** Implement the Category model with associations and methods

**Implementation:**
```ruby
# app/models/category.rb
class Category < ApplicationRecord
  has_many :cuisine_types, dependent: :nullify
  
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :display_order, presence: true
  
  # Scopes
  scope :ordered, -> { order(:display_order) }
  
  def translated_name
    I18n.t("categories.#{name.parameterize.underscore}", default: name)
  end
  
  # Get all cuisine types in this category, ordered by display_order
  def ordered_cuisine_types
    cuisine_types.order(:display_order)
  end
end
```

### 2.3 Update Factories and Tests

**Task:** Update the CuisineType factory and create a Category factory

**Implementation:**
```ruby
# spec/factories/category.rb
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:display_order)
  end
end

# spec/factories/cuisine_type.rb
FactoryBot.define do
  factory :cuisine_type do
    sequence(:name) do |n|
      CUISINE_TYPES[n % CUISINE_TYPES.length]
    end
    association :category
    sequence(:display_order)
  end

  # Define the list of valid cuisine types from seeds
  CUISINE_TYPES = %w[
    african american asian asian_fusion bakery bar bbq brazilian british
    brunch burger cafe caribbean chinese dim_sum ethiopian french fusion
    german greek indian italian japanese korean mediterranean mexican
    middle_eastern moroccan noodles other peruvian portuguese pub ramen
    seafood spanish steakhouse taiwanese thai turkish vegan vegetarian vietnamese
  ].freeze
end
```

**Task:** Create tests for the Category model

**Implementation:**
```ruby
# spec/models/category_spec.rb
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:display_order) }
  end

  describe 'associations' do
    it { should have_many(:cuisine_types).dependent(:nullify) }
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'returns categories ordered by display_order' do
        category1 = create(:category, display_order: 2)
        category2 = create(:category, display_order: 1)
        category3 = create(:category, display_order: 3)
        
        expect(Category.ordered).to eq([category2, category1, category3])
      end
    end
  end

  describe '#translated_name' do
    it 'returns the translated name if available' do
      category = create(:category, name: 'Asian')
      allow(I18n).to receive(:t).with('categories.asian', default: 'Asian').and_return('Asiatisch')
      
      expect(category.translated_name).to eq('Asiatisch')
    end
    
    it 'returns the original name if no translation is available' do
      category = create(:category, name: 'Special Category')
      allow(I18n).to receive(:t).with('categories.special_category', default: 'Special Category').and_return('Special Category')
      
      expect(category.translated_name).to eq('Special Category')
    end
  end

  describe '#ordered_cuisine_types' do
    it 'returns cuisine types ordered by display_order' do
      category = create(:category)
      cuisine_type1 = create(:cuisine_type, category: category, display_order: 2)
      cuisine_type2 = create(:cuisine_type, category: category, display_order: 1)
      cuisine_type3 = create(:cuisine_type, category: category, display_order: 3)
      
      expect(category.ordered_cuisine_types).to eq([cuisine_type2, cuisine_type1, cuisine_type3])
    end
  end
end
```

**Task:** Update tests for the CuisineType model

**Implementation:**
```ruby
# spec/models/cuisine_type_spec.rb
require 'rails_helper'

RSpec.describe CuisineType, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'associations' do
    it { should belong_to(:category).optional }
    it { should have_many(:restaurants) }
  end

  describe 'scopes' do
    describe '.by_category' do
      it 'returns cuisine types ordered by category display_order and then cuisine type display_order' do
        category1 = create(:category, display_order: 2)
        category2 = create(:category, display_order: 1)
        
        cuisine_type1 = create(:cuisine_type, category: category1, display_order: 2)
        cuisine_type2 = create(:cuisine_type, category: category1, display_order: 1)
        cuisine_type3 = create(:cuisine_type, category: category2, display_order: 1)
        
        expect(CuisineType.by_category).to eq([cuisine_type3, cuisine_type2, cuisine_type1])
      end
    end
    
    describe '.in_category' do
      it 'returns cuisine types in the specified category ordered by display_order' do
        category = create(:category)
        cuisine_type1 = create(:cuisine_type, category: category, display_order: 2)
        cuisine_type2 = create(:cuisine_type, category: category, display_order: 1)
        cuisine_type3 = create(:cuisine_type, category: create(:category), display_order: 1)
        
        expect(CuisineType.in_category(category.id)).to eq([cuisine_type2, cuisine_type1])
        expect(CuisineType.in_category(category.id)).not_to include(cuisine_type3)
      end
    end
  end

  describe '.grouped_by_category' do
    it 'returns cuisine types grouped by category' do
      category1 = create(:category)
      category2 = create(:category)
      
      cuisine_type1 = create(:cuisine_type, category: category1)
      cuisine_type2 = create(:cuisine_type, category: category1)
      cuisine_type3 = create(:cuisine_type, category: category2)
      
      grouped = CuisineType.grouped_by_category
      
      expect(grouped.keys).to contain_exactly(category1, category2)
      expect(grouped[category1]).to contain_exactly(cuisine_type1, cuisine_type2)
      expect(grouped[category2]).to contain_exactly(cuisine_type3)
    end
  end
end
```

## Phase 3: Controller and Validation Updates

### 3.1 Update CuisineTypeValidation Concern

**Task:** Modify the validation logic to handle categories

**Implementation:**
```ruby
# app/controllers/concerns/cuisine_type_validation.rb
module CuisineTypeValidation
  extend ActiveSupport::Concern

  private

  def validate_cuisine_type(cuisine_type_name)
    Rails.logger.debug "=== DEBUG: Validating cuisine type: #{cuisine_type_name} ==="
    
    if cuisine_type_name.blank?
      available_categories = format_available_categories
      return [ false, "Cuisine type is required. Available categories: #{available_categories}" ]
    end

    cuisine_type = CuisineType.find_by(name: cuisine_type_name.downcase)
    Rails.logger.debug "Found cuisine type: #{cuisine_type.inspect}"
    
    unless cuisine_type
      available_categories = format_available_categories
      error_message = "Invalid cuisine type: #{cuisine_type_name}. Available categories: #{available_categories}"
      Rails.logger.debug "Error: #{error_message}"
      return [ false, error_message ]
    end

    [ true, cuisine_type ]
  end
  
  def format_available_categories
    categories = Category.includes(:cuisine_types).ordered
    
    categories.map do |category|
      cuisine_types = category.cuisine_types.order(:display_order).pluck(:name).join(', ')
      "#{category.name} (#{cuisine_types})"
    end.join('; ')
  end
  
  # Helper method to get all cuisine types grouped by category
  def grouped_cuisine_types
    CuisineType.includes(:category).group_by(&:category)
  end
end
```

### 3.2 Update Controllers

**Task:** Update any controllers that use cuisine types

**Implementation:**
Identify and update all controllers that interact with cuisine types. For example, if there's a CuisineTypesController, update it to handle categories:

```ruby
# app/controllers/cuisine_types_controller.rb (if it exists)
class CuisineTypesController < ApplicationController
  def index
    @categories = Category.includes(:cuisine_types).ordered
    @cuisine_types_by_category = CuisineType.grouped_by_category
    
    respond_to do |format|
      format.html
      format.json { render json: @categories.as_json(include: { cuisine_types: { only: [:id, :name] } }) }
    end
  end
  
  # Other actions...
end
```

### 3.3 Update API Controllers and Serializers

**Task:** Update API controllers and serializers to handle categorized cuisine types

**Implementation:**

```ruby
# app/controllers/api/v1/cuisine_types_controller.rb (if it exists)
module Api
  module V1
    class CuisineTypesController < ApiBaseController
      def index
        @categories = Category.includes(:cuisine_types).ordered
        
        render json: {
          categories: @categories.as_json(
            only: [:id, :name],
            include: {
              cuisine_types: { only: [:id, :name] }
            }
          )
        }
      end
      
      # If you have an endpoint that returns all cuisine types without categories
      def all
        @cuisine_types = CuisineType.includes(:category).by_category
        
        render json: {
          cuisine_types: @cuisine_types.as_json(
            only: [:id, :name],
            include: {
              category: { only: [:id, :name] }
            }
          )
        }
      end
    end
  end
end
```

```ruby
# app/serializers/cuisine_type_serializer.rb (if you're using serializers)
class CuisineTypeSerializer < BaseSerializer
  attributes :id, :name, :category
  
  def category
    object.category.present? ? { id: object.category.id, name: object.category.name } : nil
  end
end
```

```ruby
# app/serializers/category_serializer.rb
class CategorySerializer < BaseSerializer
  attributes :id, :name
  
  has_many :cuisine_types
end
```

```ruby
# Update any other API controllers that use cuisine types
# For example, in RestaurantsController:

def create
  @restaurant = Restaurant.new(restaurant_params)
  @restaurant.organization = Current.organization
  
  # If your API allows setting cuisine_type_id directly
  if params[:restaurant][:cuisine_type_id].present?
    @restaurant.cuisine_type_id = params[:restaurant][:cuisine_type_id]
  # If your API uses cuisine_type_name
  elsif params[:restaurant][:cuisine_type_name].present?
    result, cuisine_or_error = validate_cuisine_type(params[:restaurant][:cuisine_type_name])
    
    if result
      @restaurant.cuisine_type = cuisine_or_error
    else
      return render_error(cuisine_or_error, :unprocessable_entity)
    end
  end
  
  # Rest of the create action...
end
```

## Phase 4: Frontend Updates

### 4.1 Update Views

**Task:** Modify cuisine type selection UI to show categorized dropdowns

**Implementation:**
```erb
<%# app/views/restaurants/_cuisine_type_modal.html.erb %>
<div id="cuisine-type-modal" class="modal">
  <div class="modal-content">
    <h2>Select Cuisine Type</h2>
    
    <div class="categories-container">
      <% Category.includes(:cuisine_types).ordered.each do |category| %>
        <div class="category">
          <h3><%= category.translated_name %></h3>
          <div class="cuisine-types">
            <% category.cuisine_types.order(:display_order).each do |cuisine_type| %>
              <div class="cuisine-type-option" data-value="<%= cuisine_type.name %>">
                <%= cuisine_type.translated_name %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    
    <div class="modal-actions">
      <button type="button" class="cancel-button">Cancel</button>
    </div>
  </div>
</div>
```

### 4.2 Update JavaScript

**Task:** Create/update JavaScript for handling categorized selection

**Implementation:**
```javascript
// frontend/controllers/cuisine_type_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "modal", "input", "display"]
  
  connect() {
    // Initialization code
  }
  
  openModal(event) {
    event.preventDefault()
    this.modalTarget.classList.add("open")
  }
  
  closeModal() {
    this.modalTarget.classList.remove("open")
  }
  
  selectCuisineType(event) {
    const cuisineType = event.currentTarget.dataset.value
    const cuisineTypeName = event.currentTarget.textContent.trim()
    
    this.inputTarget.value = cuisineType
    this.displayTarget.textContent = cuisineTypeName
    
    this.closeModal()
  }
}
```

## Phase 5: Seed Data and Migration

### 5.1 Update Seed Files

**Task:** Update the cuisine types seed file to include categories

**Implementation:**
```ruby
# db/seeds/01_categories.rb
categories = [
  { name: "African", display_order: 1 },
  { name: "Asian", display_order: 2 },
  { name: "European", display_order: 3 },
  { name: "American", display_order: 4 },
  { name: "Middle Eastern", display_order: 5 },
  { name: "Special", display_order: 6 },
  { name: "Dining Type", display_order: 7 },
  { name: "Other", display_order: 8 }
]

ActiveRecord::Base.transaction do
  categories.each do |category_data|
    Category.find_or_create_by!(name: category_data[:name]) do |category|
      category.display_order = category_data[:display_order]
    end
  end
  
  puts "Created #{Category.count} categories"
end
```

```ruby
# db/seeds/02_cuisine_types.rb (renamed from 01_cuisine_types.rb)
cuisine_types_by_category = {
  "African" => [
    { name: "african", display_order: 1 },
    { name: "ethiopian", display_order: 2 },
    { name: "eritrean", display_order: 3 },
    { name: "senegalese", display_order: 4 },
    { name: "moroccan", display_order: 5 },
    { name: "south_african", display_order: 6 },
    { name: "african_fusion", display_order: 7 }
  ],
  "Asian" => [
    { name: "asian", display_order: 1 },
    { name: "chinese", display_order: 2 },
    { name: "japanese", display_order: 3 },
    { name: "korean", display_order: 4 },
    { name: "thai", display_order: 5 },
    { name: "vietnamese", display_order: 6 },
    { name: "indian", display_order: 7 },
    { name: "taiwanese", display_order: 8 },
    { name: "asian_fusion", display_order: 9 }
  ],
  "European" => [
    { name: "european", display_order: 1 },
    { name: "french", display_order: 2 },
    { name: "italian", display_order: 3 },
    { name: "spanish", display_order: 4 },
    { name: "greek", display_order: 5 },
    { name: "german", display_order: 6 },
    { name: "polish", display_order: 7 },
    { name: "hungarian", display_order: 8 },
    { name: "russian", display_order: 9 },
    { name: "austrian", display_order: 10 },
    { name: "swiss", display_order: 11 },
    { name: "british", display_order: 12 },
    { name: "portuguese", display_order: 13 },
    { name: "mediterranean", display_order: 14 },
    { name: "scandinavian", display_order: 15 },
    { name: "european_fusion", display_order: 16 }
  ],
  "American" => [
    { name: "american", display_order: 1 },
    { name: "us", display_order: 2 },
    { name: "southern", display_order: 3 },
    { name: "bbq", display_order: 4 },
    { name: "soul_food", display_order: 5 },
    { name: "mexican", display_order: 6 },
    { name: "brazilian", display_order: 7 },
    { name: "peruvian", display_order: 8 },
    { name: "cajun", display_order: 9 },
    { name: "american_fusion", display_order: 10 }
  ],
  "Middle Eastern" => [
    { name: "middle_eastern", display_order: 1 },
    { name: "lebanese", display_order: 2 },
    { name: "turkish", display_order: 3 },
    { name: "israeli", display_order: 4 },
    { name: "persian", display_order: 5 },
    { name: "arabic", display_order: 6 },
    { name: "middle_eastern_fusion", display_order: 7 }
  ],
  "Special" => [
    { name: "special", display_order: 1 },
    { name: "vegetarian", display_order: 2 },
    { name: "vegan", display_order: 3 },
    { name: "keto", display_order: 4 },
    { name: "paleo", display_order: 5 },
    { name: "gluten_free", display_order: 6 },
    { name: "special_fusion", display_order: 7 }
  ],
  "Dining Type" => [
    { name: "dining_type", display_order: 1 },
    { name: "cafe", display_order: 2 },
    { name: "wine_bar", display_order: 3 },
    { name: "pub", display_order: 4 },
    { name: "brewery", display_order: 5 },
    { name: "fast_food", display_order: 6 },
    { name: "dining_fusion", display_order: 7 }
  ],
  "Other" => [
    { name: "other", display_order: 1 }
  ]
}

ActiveRecord::Base.transaction do
  # First, clear out all existing cuisine types that aren't associated with restaurants
  CuisineType.includes(:restaurants).where(restaurants: { id: nil }).destroy_all
  puts "Removed unused cuisine types"
  
  cuisine_types_by_category.each do |category_name, cuisine_types|
    category = Category.find_by!(name: category_name)
    
    cuisine_types.each do |cuisine_type_data|
      CuisineType.find_or_create_by!(name: cuisine_type_data[:name]) do |cuisine_type|
        cuisine_type.category = category
        cuisine_type.display_order = cuisine_type_data[:display_order]
      end
    end
  end
  
  puts "Created #{CuisineType.count} cuisine types"
  
  # Get the "Other" cuisine type
  other_cuisine = CuisineType.find_by!(name: "other")
  
  # Update existing restaurants without a cuisine type
  restaurants_updated = Restaurant.where(cuisine_type_id: nil).update_all(cuisine_type_id: other_cuisine.id)
  
  puts "Updated #{restaurants_updated} restaurants with 'Other' cuisine type"
  
  # Map old cuisine types to new ones
  cuisine_type_mapping = {
    'african' => 'african_fusion',
    'asian' => 'asian_fusion',
    'asian_fusion' => 'asian_fusion',
    'bakery' => 'cafe',
    'bar' => 'pub',
    'brunch' => 'cafe',
    'burger' => 'fast_food',
    'caribbean' => 'american_fusion',
    'dim_sum' => 'chinese',
    'fusion' => 'special_fusion',
    'middle_eastern' => 'middle_eastern_fusion',
    'noodles' => 'asian_fusion',
    'ramen' => 'japanese',
    'seafood' => 'european_fusion',
    'steakhouse' => 'american_fusion',
    'turkish' => 'turkish',
    # Keeping: taiwanese, portuguese, peruvian, mediterranean
  }
  
  # Update restaurants with mapped cuisine types
  cuisine_type_mapping.each do |old_name, new_name|
    old_cuisine = CuisineType.find_by(name: old_name)
    next unless old_cuisine && old_cuisine.restaurants.any?
    
    new_cuisine = CuisineType.find_by(name: new_name)
    if new_cuisine
      count = Restaurant.where(cuisine_type_id: old_cuisine.id).update_all(cuisine_type_id: new_cuisine.id)
      puts "Updated #{count} restaurants from '#{old_name}' to '#{new_name}'"
    end
  end
end
```

## Phase 6: Testing and Deployment

### 6.1 Comprehensive Testing

**Task:** Update and run all tests

**Implementation:**
1. Run the test suite to identify failing tests
2. Update all tests that interact with cuisine types
3. Add tests for the new category functionality
4. Ensure all tests pass before deployment

### 6.2 Deployment Strategy

**Task:** Plan and execute deployment

**Implementation:**
1. Create a backup of the production database
2. Run migrations in production
3. Monitor the application for any issues
4. Have a rollback plan ready if needed

## Implementation Timeline

- **Phase 1 (Database Changes)**: 1-2 days
- **Phase 2 (Model Updates)**: 1 day
- **Phase 3 (Controller Updates)**: 1 day
- **Phase 4 (Frontend Updates)**: 2-3 days
- **Phase 5 (Seed Data)**: 1 day
- **Phase 6 (Testing & Deployment)**: 1-2 days

Total estimated time: 6-9 days

## Potential Challenges and Mitigations

1. **Data Migration Issues**
   - Challenge: Existing cuisine types might not map cleanly to categories
   - Mitigation: Create an "Other" category for unmapped cuisine types

2. **UI/UX Complexity**
   - Challenge: Categorized selection might be more complex for users
   - Mitigation: Ensure the UI is intuitive and provides clear visual hierarchy

3. **Performance Concerns**
   - Challenge: Additional joins and queries might impact performance
   - Mitigation: Use eager loading and optimize queries where necessary

4. **Testing Coverage**
   - Challenge: Ensuring all edge cases are covered in tests
   - Mitigation: Add comprehensive tests for each functionality

5. **API Changes**
   - Challenge: Updating API controllers and serializers
   - Mitigation: Update API controllers and serializers to handle categorized cuisine types

## Conclusion

This plan provides a comprehensive approach to transitioning from a flat cuisine type structure to a hierarchical categorization system. By following these steps, we can implement the new system with minimal disruption while providing a better user experience for cuisine type selection.
