# frozen_string_literal: true

class VisitCardComponentPreview < ViewComponent::Preview
  def default
    render(VisitCardComponent.new)
  end
end
