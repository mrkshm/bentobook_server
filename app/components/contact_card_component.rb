class ContactCardComponent < ViewComponent::Base
  include HeroiconHelper

  def initialize(contact:)
    @contact = contact
  end

  private

  attr_reader :contact
end
