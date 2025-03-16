module Shared
  class FlashComponent < ViewComponent::Base
    TYPES = {
      notice: "bg-primary-100 text-primary-700 border-primary-200",
      success: "bg-success-100 text-success-700 border-success-200",
      warning: "bg-warning-100 text-warning-700 border-warning-200",
      error: "bg-error-100 text-error-700 border-error-200",
      alert: "bg-error-100 text-error-700 border-error-200" # alias for error
    }.freeze

    def initialize(type:, message:)
      @type = type.to_sym
      @message = message
      @classes = TYPES[@type] || TYPES[:notice]
    end

    private

    attr_reader :type, :message, :classes
  end
end
