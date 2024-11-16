class ListComponent < ViewComponent::Base
  def initialize(list:, current_user:)
    @list = list
    @current_user = current_user
    @statistics = ListStatistics.new(list: list, user: current_user)
    @is_shared = list.owner != current_user
    @permissions = {
      can_edit: list.editable_by?(current_user),
      can_delete: list.owner == current_user
    }
  end

  private

  attr_reader :list, :current_user, :statistics, :permissions, :is_shared
end
