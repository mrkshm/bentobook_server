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

      if @visit.restaurant_id.blank?
        flash.now[:alert] = I18n.t('errors.visits.restaurant_required')
        @visit.errors.add(:restaurant_id, :blank)
        render :new, status: :unprocessable_entity
      elsif @visit.valid?
        begin
          if @visit.save
            process_images
            redirect_to visits_path, notice: I18n.t("notices.visits.created")
          else
            flash.now[:alert] = I18n.t('errors.visits.save_failed')
            render :new, status: :unprocessable_entity
          end
        rescue StandardError => e
          flash.now[:alert] = I18n.t('errors.visits.image_processing_failed')
          Rails.logger.error "Image processing failed: #{e.message}"
          @visit.destroy if @visit.persisted?
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = I18n.t('errors.visits.save_failed')
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit
        # @visit is already set by set_visit
    end
  
    def update
      if @visit.update(visit_params)
        if params[:visit][:images].present?
          process_images
        end

        redirect_to visits_path, notice: I18n.t("notices.visits.updated")
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
  
    def process_images
      return unless params[:visit][:images].present?
      
      # Filter out any empty strings that might be in the array
      images = Array(params[:visit][:images]).reject(&:blank?)
      
      images.each do |image|
        @visit.images.create(file: image)
      end
    rescue StandardError => e
      Rails.logger.error "Image processing failed: #{e.message}"
      flash[:alert] = I18n.t('errors.visits.image_processing_failed')
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
      if @visit.restaurant_id.nil?
        flash.now[:alert] = I18n.t('errors.visits.restaurant_required')
        @visit.errors.add(:restaurant_id, :blank)
        render render_action, status: :unprocessable_entity
      elsif @visit.save
        begin
          process_images
          flash[:notice] = I18n.t("notices.visits.#{render_action == :new ? 'created' : 'updated'}")
          redirect_to visits_path
        rescue StandardError => e
          flash[:alert] = I18n.t('errors.visits.image_processing_failed')
          Rails.logger.error "Image processing failed: #{e.message}"
          @visit.destroy
          render render_action, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = I18n.t('errors.visits.save_failed')
        render render_action, status: :unprocessable_entity
      end
    end
  end
