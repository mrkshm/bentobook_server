namespace :avatars do
  desc "Migrate existing avatars to the new two-size system with WebP format"
  task migrate: :environment do
    puts "Starting avatar migration..."
    total = Profile.joins(avatar_attachment: :blob).count
    success = 0
    failed = 0

    Profile.find_each do |profile|
      if profile.avatar.attached?
        puts "\nProcessing avatar for profile #{profile.id}..."

        begin
          # Download the original avatar
          blob = profile.avatar.blob
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
            profile.avatar.purge

            # Attach new variants
            profile.avatar_medium.attach(result[:variants][:medium])
            profile.avatar_thumbnail.attach(result[:variants][:thumbnail])

            success += 1
            puts "  ✓ Successfully migrated avatar for profile #{profile.id}"
            puts "    → Medium: #{result[:variants][:medium][:filename]}"
            puts "    → Thumbnail: #{result[:variants][:thumbnail][:filename]}"
          else
            failed += 1
            puts "  ✗ Failed to process avatar for profile #{profile.id}: #{result[:error]}"
          end

        rescue StandardError => e
          failed += 1
          puts "  ✗ Error processing avatar for profile #{profile.id}: #{e.message}"
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
