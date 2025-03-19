module Visits
  class ImagesController < ApplicationController
    include Turbo::Frames
    before_action :authenticate_user!
    before_action :set_visit

    def new
      @images = @visit.images
    end

    def create
      if params[:images].present?
        result = ImageProcessorService.new(@visit, params[:images]).process

        if result.success?
          respond_to do |format|
            format.turbo_stream {
              redirect_to visit_path(id: @visit.id, locale: current_locale),
                notice: t("notices.images.created")
            }
            format.html {
              redirect_to visit_path(id: @visit.id, locale: current_locale),
                notice: t("notices.images.created")
            }
          end
        else
          flash.now[:alert] = result.error
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = t("errors.images.none_selected")
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @images = @visit.images
    end

    private

    def set_visit
      @visit = current_user.visits.find(params[:visit_id])
    end
  end
end
