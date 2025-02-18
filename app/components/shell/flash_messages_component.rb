# frozen_string_literal: true

module Shell
  class FlashMessagesComponent < ViewComponent::Base
    def initialize(notice: nil, alert: nil)
      @notice = notice
      @alert = alert
    end

    private

    attr_reader :notice, :alert
  end
end
