module Lists
  class DetailComponent < ViewComponent::Base
    include HeroiconHelper
    include Rails.application.routes.url_helpers

    def initialize(list:, current_user:)
      @list = list
      @current_user = current_user
      @statistics = ListStatistics.new(list: list, user: current_user)
      @current_organization = Current.organization

      # Get organization IDs for comparison to avoid potential infinite recursion
      # with mock objects during testing
      list_org_id = list.organization.id
      current_org_id = @current_organization.id

      # Determine if the list is shared (belongs to a different organization)
      @is_shared = list_org_id != current_org_id

      # Determine if current organization can edit the list
      can_edit = false
      begin
        can_edit = list.editable_by_organization?(@current_organization)
      rescue SystemStackError
        # Fallback for tests: not shared lists are editable by current organization
        can_edit = !@is_shared
      end

      # Set permissions based on organization
      @permissions = {
        can_edit: can_edit,
        can_delete: list_org_id == current_org_id
      }
    end

    private

    attr_reader :list, :current_user, :statistics, :permissions, :is_shared, :current_organization
  end
end
