module Visits
  module PricePaid
    class FormComponent < ViewComponent::Base
      include Turbo::FramesHelper
      include ActionView::RecordIdentifier
      include HeroiconHelper
      include Rails.application.routes.url_helpers

      def initialize(visit:)
        @visit = visit
      end

      private

      attr_reader :visit

      def frame_id
        dom_id(visit, :price_paid)
      end

      def default_currency
        visit.price_paid&.currency&.iso_code || "USD"
      end

      def supported_currencies
        Bentobook::Currencies::SUPPORTED_CURRENCIES.flatten(1)  # Flatten because map creates nested array
      end

      def formatted_amount
        return nil unless visit.price_paid
        # Format to always show 2 decimal places
        "%.2f" % visit.price_paid.amount
      end
    end
  end
end
