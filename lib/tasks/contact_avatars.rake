namespace :contacts do
  desc "Migrate existing contact avatars to the new two-size system with WebP format"
  task migrate_avatars: :environment do
    puts "Starting contact avatar migration..."
    total = Contact.joins(avatar_attachment: :blob).count
    success = 0
    failed = 0

    Contact.find_each do |contact|
      if contact.avatar.attached?
        puts "\nProcessing avatar for contact #{contact.id} (#{contact.name})..."

        begin
          # Download the original avatar
          blob = contact.avatar.blob
          tempfile = Tempfile.new([ "avatar", PreprocessAvatarService::OUTPUT_EXTENSION ])
          tempfile.binmode
          tempfile.write(blob.download)
          tempfile.rewind

          # Create a mock uploaded file
          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: tempfile,
            filename: "original#{PreprocessAvatarService::OUTPUT_EXTENSION}",
            type: PreprocessAvatarService::OUTPUT_CONTENT_TYPE
          )

          # Process the avatar using our service
          result = PreprocessAvatarService.call(uploaded_file)

          if result[:success]
            # Remove old avatar
            contact.avatar.purge

            # Attach new variants
            contact.avatar_medium.attach(result[:variants][:medium])
            contact.avatar_thumbnail.attach(result[:variants][:thumbnail])

            success += 1
            puts "  ✓ Successfully migrated avatar for contact #{contact.id}"
            puts "    → Medium: #{result[:variants][:medium][:filename]}"
            puts "    → Thumbnail: #{result[:variants][:thumbnail][:filename]}"
          else
            failed += 1
            puts "  ✗ Failed to process avatar for contact #{contact.id}: #{result[:error]}"
          end

        rescue StandardError => e
          failed += 1
          puts "  ✗ Error processing avatar for contact #{contact.id}: #{e.message}"
          puts "    #{e.backtrace.first(5).join("\n    ")}"
        ensure
          tempfile&.close
          tempfile&.unlink
        end
      end
    end

    puts "\nMigration complete!"
    puts "Total processed: #{total}"
    puts "Successful: #{success}"
    puts "Failed: #{failed}"
  end
end
