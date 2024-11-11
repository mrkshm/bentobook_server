class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = current_user.lists.order(created_at: :desc)
  end

  def show
    @order_by = params[:order_by] || 'name'
    @order_direction = params[:order_direction] || 'asc'

    @restaurants = @list.restaurants
      .includes(:cuisine_type)
      .order(@order_by => @order_direction)

    @sort_fields = {
      'name' => t('restaurants.attributes.name'),
      'cuisine_types.name' => t('restaurants.attributes.cuisine_type'),
      'created_at' => t('common.sort.recently_added'),
    }

    respond_to do |format|
      format.html
      format.text do
        send_data ListMarkdownExporter.new(@list).generate,
                  filename: "#{@list.name.parameterize}-restaurants.md",
                  type: 'text/markdown'
      end
    end
  end

  def new
    @list = current_user.lists.build
  end

  def create
    @list = current_user.lists.build(list_params)
    
    if @list.save
      redirect_to @list, notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to list_path, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_path, notice: t('.success'), status: :see_other
  end

  def export
    @list = current_user.lists.find(params[:id])
    
    respond_to do |format|
      format.text do
        send_data ListMarkdownExporter.new(@list).generate,
                  filename: "#{@list.name.parameterize}-restaurants.md",
                  type: 'text/markdown'
      end
      
      format.html do
        if params[:email].present?
          ListMailer.export(@list, params[:email]).deliver_later
          redirect_to @list, notice: t('.email_sent', email: params[:email])
        else
          render :export_modal, layout: false
        end
      end
    end
  end

  private

  def set_list
    @list = current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :description, :visibility)
  end
end
