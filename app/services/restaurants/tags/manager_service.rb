module Restaurants
  module Tags
    class ManagerService
      MAX_TAGS = 30
      MAX_TAG_LENGTH = 50

      def initialize(record)
        @record = record
      end

      def update(tags)
        return Result.error("Invalid type") unless tags.nil? || tags.is_a?(String) || tags.is_a?(Array)
        return Result.error("No tags provided") if tags.nil?

        tags = parse_tags(tags)
        return Result.error("Invalid tag format") unless tags

        if tags.any? { |tag| tag.length > MAX_TAG_LENGTH }
          return Result.error("Tags must be #{MAX_TAG_LENGTH} characters or less")
        end

        if tags.size > MAX_TAGS
          return Result.error("Maximum #{MAX_TAGS} tags allowed")
        end

        @record.tag_list = tags

        if @record.save
          Result.success
        else
          Result.error("Failed to save tags")
        end
      rescue => e
        Rails.logger.error "Error updating tags: #{e.message}"
        Result.error("Failed to save tags")
      end

      private

      def parse_tags(tags)
        case tags
        when String
          JSON.parse(tags)
        when Array
          tags
        else
          nil
        end
      rescue JSON::ParserError
        nil
      end
    end

    class Result
      attr_reader :success, :error

      def self.success
        new(true)
      end

      def self.error(message)
        new(false, message)
      end

      def initialize(success, error = nil)
        @success = success
        @error = error
      end

      def success?
        @success
      end
    end
  end
end
