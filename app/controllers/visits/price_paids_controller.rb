module Visits
  class PricePaidsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_visit

    def show
      render(Visits::PricePaidComponent.new(visit: @visit))
    end

    def edit
      respond_to do |format|
        format.html { render template: "visits/price_paids/edit" }
        format.turbo_stream { render template: "visits/price_paids/edit" }
      end
    end

    def update
      if @visit.update(price_paid_params)
        respond_to do |format|
          if hotwire_native_app?
            format.html { redirect_to visit_path(id: @visit.id) }
          else
            format.turbo_stream do
              render turbo_stream: turbo_stream.update("modal", "") +
                                   turbo_stream.replace(dom_id(@visit, :price_paid), partial: "visits/price_paids/display", locals: { visit: @visit.reload })
            end
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @visit.update(price_paid: nil)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("modal", "") +
                               turbo_stream.replace(dom_id(@visit, :price_paid), partial: "visits/price_paids/display", locals: { visit: @visit.reload })
        end
      end
    end

    private

    def set_visit
      @visit = Current.organization.visits.find(params[:visit_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to visits_path, alert: t("errors.visits.not_found")
    end

    def price_paid_params
      params.require(:visit).permit(:price_paid, :price_paid_currency)
    end
  end
end
