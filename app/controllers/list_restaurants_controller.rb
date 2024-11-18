class ListRestaurantsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  before_action :set_list
  before_action :ensure_editable, except: [:import, :import_all]
  include Pagy::Backend
  
  def index
    @pagy, @restaurants = pagy(
      Restaurant.search_by_full_text(params[:query])
        .includes(:cuisine_type)
        .order(:name)
    )
    
    render :new
  end

  def new
    @pagy, @restaurants = pagy(
      Restaurant.search_by_full_text(params[:query])
        .includes(:cuisine_type)
        .order(:name)
    )
  end

  def create
    @list_restaurant = @list.list_restaurants.build(restaurant_id: params[:restaurant_id])
    
    if @list_restaurant.save
      redirect_to list_path(id: @list.id), notice: t('.success')
    else
      redirect_to list_path(id: @list.id), alert: t('.error')
    end
  end

  def destroy
    @list_restaurant = @list.list_restaurants.find(params[:id])
    @list_restaurant.destroy
    
    flash[:notice] = t('.success')
    redirect_to edit_list_list_restaurants_path(list_id: @list.id)
  end

  def import_all
    restaurants_to_import = @list.restaurants.where.not(
      id: RestaurantCopy.where(user: current_user).select(:restaurant_id)
    )
    
    imported_count = 0
    
    ActiveRecord::Base.transaction do
      restaurants_to_import.each do |restaurant|
        copied_restaurant = restaurant.copy_for_user(current_user)
        imported_count += 1 if copied_restaurant.persisted?
      end
    end
    
    respond_to do |format|
      format.html do
        redirect_to list_path(id: @list.id), 
          notice: t('.success', count: imported_count)
      end
      format.turbo_stream do
        flash.now[:notice] = t('.success', count: imported_count)
        render turbo_stream: turbo_stream.update('flash', partial: 'shared/flash'), status: :ok
      end
    end
  end

  def import
    restaurant = @list.restaurants.find(params[:id])
    copied_restaurant = restaurant.copy_for_user(current_user)
    
    respond_to do |format|
      format.html do
        if copied_restaurant.persisted?
          redirect_to list_path(id: @list.id), notice: t('.success')
        else
          redirect_to list_path(id: @list.id), alert: t('.error')
        end
      end
      format.turbo_stream do
        if copied_restaurant.persisted?
          flash.now[:notice] = t('.success')
          render turbo_stream: [
            turbo_stream.replace(
              dom_id(restaurant, :import),
              partial: 'lists/restaurant_imported',
              locals: { restaurant: restaurant }
            ),
            turbo_stream.update('flash', partial: 'shared/flash')
          ]
        else
          flash.now[:alert] = t('.error')
          render turbo_stream: turbo_stream.update('flash', partial: 'shared/flash')
        end
      end
    end
  end

  private

  def set_list
    @list = List.left_joins(:shares)
      .where(
        'lists.owner_id = :user_id OR (shares.recipient_id = :user_id AND shares.status = :status)',
        user_id: current_user.id,
        status: Share.statuses[:accepted]
      )
      .find(params[:list_id])
  end

  def ensure_editable
    unless @list.editable_by?(current_user)
      redirect_to list_path(id: @list.id), alert: t('.not_authorized')
    end
  end
end
