# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load cuisine type categories
load Rails.root.join('db', 'seeds', 'cuisine_types', '01_categories.rb')

# Load cuisine types with categories
load Rails.root.join('db', 'seeds', 'cuisine_types', '02_cuisine_types.rb')
