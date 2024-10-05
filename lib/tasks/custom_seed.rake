namespace :db do
    namespace :seed do
      Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |filename|
        task_name = File.basename(filename, '.rb').intern
        task task_name => :environment do
          puts "Seeding #{filename}..."
          begin
            load(filename) if File.exist?(filename)
            puts "Completed seeding #{filename}"
          rescue => e
            puts "Error seeding #{filename}: #{e.message}"
            puts e.backtrace
          end
        end
      end

      desc "Run all seed files in order"
      task :all => :environment do
        Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |filename|
          Rake::Task["db:seed:#{File.basename(filename, '.rb')}"].invoke
        end
      end
    end
  end