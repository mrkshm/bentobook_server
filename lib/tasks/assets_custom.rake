namespace :assets do
  desc "Precompile assets with workaround for Tailwind truncation"
  task :precompile_with_fix => :environment do
    # Store the complete CSS file content
    complete_css_path = Rails.root.join("app/assets/builds/tailwind.css")
    complete_css_content = nil
    
    if File.exist?(complete_css_path)
      complete_css_content = File.read(complete_css_path)
      puts "Stored complete CSS file: #{complete_css_content.size} bytes"
    end
    
    # Run normal asset precompilation with Tailwind disabled
    ENV['SKIP_TAILWINDCSS_BUILD'] = '1'
    Rake::Task["assets:precompile"].invoke
    
    # Find the generated CSS file and replace it with complete content
    if complete_css_content
      css_files = Dir.glob(Rails.root.join("public/assets/tailwind-*.css"))
      css_files.each do |css_file|
        current_size = File.size(css_file)
        if current_size < 50000
          puts "Replacing truncated CSS file #{css_file} (#{current_size} bytes) with complete version"
          File.write(css_file, complete_css_content)
          puts "Replacement complete: #{File.size(css_file)} bytes"
        else
          puts "CSS file #{css_file} appears complete: #{current_size} bytes"
        end
      end
    end
  end
end