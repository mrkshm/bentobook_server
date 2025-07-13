namespace :restaurants do
  desc "Migrate Google restaurant data to restaurant fields (excluding rating)"
  task migrate_from_google: :environment do
    puts "🚀 Starting Google → Restaurant data migration..."
    
    # Count restaurants that need migration
    restaurants_with_google = Restaurant.joins(:google_restaurant)
    total_count = restaurants_with_google.count
    
    if total_count == 0
      puts "ℹ️  No restaurants with Google data found. Nothing to migrate."
      exit
    end
    
    puts "📊 Found #{total_count} restaurants with Google data"
    
    # Show what fields will be migrated
    puts "\n📋 Fields to migrate (if restaurant field is blank):"
    puts "   • name"
    puts "   • address" 
    puts "   • latitude"
    puts "   • longitude"
    puts "   • phone_number"
    puts "   • url"
    puts "   • business_status"
    puts "   • price_level"
    puts "   • street_number"
    puts "   • street"
    puts "   • postal_code"
    puts "   • city"
    puts "   • state"
    puts "   • country"
    puts "\n❌ Excluded: google_rating (keeping user ratings separate)"
    
    puts "\n✅ Proceeding with migration (use preview_migration for dry run)..."
    
    puts "\n🔄 Starting migration..."
    
    updated_count = 0
    skipped_count = 0
    
    restaurants_with_google.includes(:google_restaurant).find_each.with_index do |restaurant, index|
      google = restaurant.google_restaurant
      
      # Skip if no Google data
      unless google
        skipped_count += 1
        next
      end
      
      # Prepare update attributes (only if restaurant field is blank)
      updates = {}
      
      # Core info
      updates[:name] = google.name if restaurant.name.blank? && google.name.present?
      updates[:address] = google.address if restaurant.address.blank? && google.address.present?
      
      # Location
      updates[:latitude] = google.latitude if restaurant.latitude.blank? && google.latitude.present?
      updates[:longitude] = google.longitude if restaurant.longitude.blank? && google.longitude.present?
      
      # Contact info
      updates[:phone_number] = google.phone_number if restaurant.phone_number.blank? && google.phone_number.present?
      updates[:url] = google.url if restaurant.url.blank? && google.url.present?
      
      # Business info
      updates[:business_status] = google.business_status if restaurant.business_status.blank? && google.business_status.present?
      updates[:price_level] = google.price_level if restaurant.price_level.blank? && google.price_level.present?
      
      # Address components
      updates[:street_number] = google.street_number if restaurant.street_number.blank? && google.street_number.present?
      updates[:street] = google.street if restaurant.street.blank? && google.street.present?
      updates[:postal_code] = google.postal_code if restaurant.postal_code.blank? && google.postal_code.present?
      updates[:city] = google.city if restaurant.city.blank? && google.city.present?
      updates[:state] = google.state if restaurant.state.blank? && google.state.present?
      updates[:country] = google.country if restaurant.country.blank? && google.country.present?
      
      # Skip if no updates needed
      if updates.empty?
        skipped_count += 1
      else
        # Update restaurant
        restaurant.update!(updates)
        updated_count += 1
        
        # Progress indicator
        if (index + 1) % 50 == 0
          puts "   ✅ Processed #{index + 1}/#{total_count} restaurants..."
        end
      end
    end
    
    puts "\n🎉 Migration completed!"
    puts "   📈 Updated: #{updated_count} restaurants"
    puts "   ⏭️  Skipped: #{skipped_count} restaurants (no updates needed)"
    puts "   📊 Total: #{total_count} restaurants processed"
    
    if updated_count > 0
      puts "\n💡 Next steps:"
      puts "   1. Test your app to make sure everything works"
      puts "   2. Remove fallback methods from Restaurant model"
      puts "   3. Keep google_restaurant for future syncing only"
    end
    
    puts "\n✨ Done!"
  end
  
  desc "Preview what the migration would do (dry run)"
  task preview_migration: :environment do
    puts "🔍 PREVIEW: Google → Restaurant data migration (DRY RUN)"
    
    restaurants_with_google = Restaurant.joins(:google_restaurant).includes(:google_restaurant)
    total_count = restaurants_with_google.count
    
    if total_count == 0
      puts "ℹ️  No restaurants with Google data found."
      exit
    end
    
    puts "📊 Found #{total_count} restaurants with Google data"
    
    would_update = 0
    would_skip = 0
    
    restaurants_with_google.limit(10).each do |restaurant|
      google = restaurant.google_restaurant
      next unless google
      
      updates = []
      updates << "name" if restaurant.name.blank? && google.name.present?
      updates << "address" if restaurant.address.blank? && google.address.present?
      updates << "latitude" if restaurant.latitude.blank? && google.latitude.present?
      updates << "longitude" if restaurant.longitude.blank? && google.longitude.present?
      updates << "phone_number" if restaurant.phone_number.blank? && google.phone_number.present?
      # ... etc
      
      if updates.any?
        puts "   📝 #{restaurant.id}: would update #{updates.join(', ')}"
        would_update += 1
      else
        would_skip += 1
      end
    end
    
    puts "\n📈 Summary (first 10 restaurants):"
    puts "   Would update: #{would_update}"
    puts "   Would skip: #{would_skip}"
    puts "\n🏃‍♂️ Run 'rails restaurants:migrate_from_google' to execute"
  end
end