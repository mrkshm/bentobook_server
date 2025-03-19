class ContactListComponent < ViewComponent::Base
  include HeroiconHelper

  def initialize(contacts:, visit:)
    @contacts = contacts
    @visit = visit
  end

  private

  attr_reader :contacts, :visit
end
