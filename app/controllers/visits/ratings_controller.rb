module Visits
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_visit

    def show
      render partial: "visits/ratings/display", locals: { visit: @visit }
    end

    def edit
      render template: "visits/ratings/edit"
    end

    def update
      if @visit.update(rating_params)
        # Force cache control headers to prevent stale data
        response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"

        if hotwire_native_app?
          # Add timestamp to URL to bust cache
          timestamp = Time.current.to_i
          redirect_url = visit_path(id: @visit.id, locale: current_locale, t: timestamp)

          redirect_to redirect_url,
            data: { turbo_action: "replace", turbo_frame: "_top" }
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@visit, :rating),
            partial: "visits/ratings/display", locals: { visit: @visit.reload }
          )
        end
      else
        render template: "visits/ratings/edit",
               status: :unprocessable_entity
      end
    end

    private

    def set_visit
      @visit = Current.organization.visits.find(params[:visit_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to visits_path, alert: t("errors.visits.not_found")
    end

    def rating_params
      params.require(:visit).permit(:rating)
    end
  end
end
