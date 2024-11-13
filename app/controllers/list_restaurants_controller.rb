class ListRestaurantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list
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
    @list_restaurant = @list.list_restaurants.find_by!(restaurant_id: params[:restaurant_id])
    @list_restaurant.destroy
    
    flash[:notice] = t('.success')
    redirect_to edit_list_list_restaurants_path(list_id: @list.id)
  end

  private

  def set_list
    @list = current_user.lists.find(params[:list_id])
  end
end
