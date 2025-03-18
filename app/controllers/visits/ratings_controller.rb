module Visits
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_visit

    def show
      render(Visits::RatingComponent.new(visit: @visit))
    end

    def edit
      render(Visits::Rating::FormComponent.new(visit: @visit))
    end

    def update
      if @visit.update(rating_params)
        respond_to do |format|
          if hotwire_native_app?
            format.html { redirect_to visit_path(id: @visit.id, locale: nil) }
          else
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                dom_id(@visit, :rating),
                Visits::RatingComponent.new(visit: @visit).render_in(view_context)
              )
            end
          end
        end
      else
        render(Visits::Rating::FormComponent.new(visit: @visit), status: :unprocessable_entity)
      end
    end

    private

    def set_visit
      @visit = current_user.visits.find(params[:visit_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to visits_path, alert: t("errors.visits.not_found")
    end

    def rating_params
      params.require(:visit).permit(:rating)
    end
  end
end
