# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
    include HeroiconHelper

    def call
        content
    end
end
