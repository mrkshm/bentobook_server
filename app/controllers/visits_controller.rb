class VisitsController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_user!
    before_action :set_visit, only: [:show, :edit, :update, :destroy]
    before_action :ensure_valid_restaurant, only: [:create, :update]
  
    def index
      @pagy, @visits = pagy(current_user.visits.includes(:restaurant, :contacts, images: { file_attachment: :blob }))
    end
  
    def show
      # This action will render the show view
    end
  
    def new
      @visit = Visit.new
      @visit.restaurant_id = params[:restaurant_id] if params[:restaurant_id].present?
    end
  
    def create
      @visit = current_user.visits.build(visit_params)
      save_visit(:new)
    end
  
    def edit
        # @visit is already set by set_visit
    end
  
    def update
      if @visit.update(visit_params)
        save_visit(:edit)
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      @visit.destroy
      redirect_to visits_path, notice: I18n.t('notices.visits.deleted')
    end
  
    private
  
    def set_visit
      @visit = current_user.visits.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = I18n.t('errors.visits.not_found')
        redirect_to visits_path
    end
  
    def visit_params
      params.require(:visit).permit(
        :date, 
        :title, 
        :notes, 
        :restaurant_id, 
        :rating, 
        :price_paid, 
        :price_paid_currency,
        contact_ids: []
      ).tap do |whitelisted|
        if whitelisted[:price_paid].present?
          whitelisted[:price_paid] = Money.from_amount(whitelisted[:price_paid].to_f, whitelisted[:price_paid_currency] || 'USD')
        end
      end
    end
  
    def valid_restaurant?(restaurant_id)
      current_user.restaurants.exists?(restaurant_id)
    end
  
    def ensure_valid_restaurant
      return if params[:visit].blank? || params[:visit][:restaurant_id].blank?
      unless valid_restaurant?(params[:visit][:restaurant_id])
        flash.now[:alert] = I18n.t('errors.visits.invalid_restaurant')
        @visit ||= Visit.new
        @visit.errors.add(:restaurant_id, :invalid)
        render :new, status: :unprocessable_entity
      end
    end
  
    def save_visit(render_action)
      if @visit.restaurant_id.blank?
        flash.now[:alert] = I18n.t('errors.visits.restaurant_required')
        @visit.errors.add(:restaurant_id, :blank)
        render render_action, status: :unprocessable_entity
      elsif @visit.persisted? || @visit.save
        if params[:visit][:images].present?
          begin
            result = ImageProcessorService.new(@visit, params[:visit][:images]).process
            unless result.success?
              flash[:alert] = result.error
              raise StandardError, "Image processing failed"
            end
            redirect_to visits_path, notice: I18n.t("notices.visits.#{render_action == :new ? 'created' : 'updated'}")
          rescue StandardError => e
            Rails.logger.error "Image processing failed: #{e.message}"
            @visit.destroy if render_action == :new
            render render_action, status: :unprocessable_entity
          end
        else
          redirect_to visits_path, notice: I18n.t("notices.visits.#{render_action == :new ? 'created' : 'updated'}")
        end
      else
        flash.now[:alert] = I18n.t('errors.visits.save_failed')
        render render_action, status: :unprocessable_entity
      end
    end
  end
