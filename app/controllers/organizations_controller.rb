class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def search
    return head(:bad_request) unless request.xhr?

    @organizations = Organization.where.not(id: Current.organization.id)
                               .where("organizations.username ILIKE :query OR
                                     organizations.name ILIKE :query",
                                     query: "%#{params[:query]}%")
                               .limit(5)

    Rails.logger.info "Found #{@organizations.count} matching organizations"

    render partial: "organizations/search_results",
           formats: [ :html ],
           layout: false,
           status: :ok
  end
end
