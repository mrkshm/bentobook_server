class ActiveRecord::QueryCounter
    class << self
      def count
        ActiveSupport::Notifications.subscribed(lambda { |*args| 
          payload = args.last
          unless payload[:name] =~ /CACHE/ || payload[:sql] =~ /BEGIN|COMMIT/
            @count += 1
          end
        }, "sql.active_record") do
          @count = 0
          yield
          @count
        end
      end
    end
end