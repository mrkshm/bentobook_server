# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
    include HeroiconHelper
    include LocaleHelper

    def call
        content
    end
end
