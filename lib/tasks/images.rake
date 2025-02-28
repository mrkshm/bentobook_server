namespace :images do
  desc "Generate missing variants for all existing images"
  task generate_variants: :environment do
    puts "Starting to generate missing variants for existing images..."
    
    total = Image.count
    success = 0
    failed = 0
    
    Image.find_each.with_index do |image, index|
      begin
        if image.file.attached?
          # Create medium and large variants only (as they work)
          variants = [
            # Medium
            image.file.variant(resize_to_limit: [600, 400], format: :webp, saver: { quality: 80 }),
            # Large
            image.file.variant(resize_to_limit: [1200, 800], format: :webp, saver: { quality: 80 })
          ]
          
          # Force immediate processing of variants
          variants.each do |variant|
            begin
              # Force variant processing by accessing the key and processed variant
              variant.key
              variant.processed if variant.respond_to?(:processed)
              puts "Successfully processed variant for Image ##{image.id}"
            rescue => e
              puts "Error processing specific variant for Image ##{image.id}: #{e.message}"
            end
          end
          
          success += 1
          print "." if (index % 5).zero?
        else
          puts "\nImage ##{image.id} has no attached file!"
          failed += 1
        end
      rescue => e
        puts "\nError processing Image ##{image.id}: #{e.message}"
        failed += 1
      end
    end
    
    puts "\nVariant generation complete!"
    puts "Processed #{total} images:"
    puts "  - Success: #{success}"
    puts "  - Failed: #{failed}"
  end

  desc "Fix problematic images"
  task fix_images: :environment do
    puts "Checking for problematic images..."
    
    Image.find_each do |image|
      if image.file.attached?
        original_content_type = image.file.blob.content_type
        
        # Fix incorrect content types
        if original_content_type.nil? || original_content_type.empty?
          extension = File.extname(image.file.blob.filename.to_s).downcase
          new_content_type = case extension
                             when '.jpg', '.jpeg' then 'image/jpeg'
                             when '.png' then 'image/png'
                             when '.webp' then 'image/webp'
                             when '.gif' then 'image/gif'
                             else 'image/jpeg'
                             end
          
          puts "Fixing content type for Image ##{image.id} from '#{original_content_type}' to '#{new_content_type}'"
          image.file.blob.update!(content_type: new_content_type)
        end
      end
    end
    
    puts "Image fixing complete!"
  end
end