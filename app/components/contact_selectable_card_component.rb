class ContactSelectableCardComponent < ViewComponent::Base
  include HeroiconHelper

  def initialize(contact:, visit:)
    @contact = contact
    @visit = visit
  end

  private

  attr_reader :contact, :visit
end
