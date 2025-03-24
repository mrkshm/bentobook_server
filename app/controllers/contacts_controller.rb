class ContactsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]

  def index
    items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 12
    page = params[:page].to_i.positive? ? params[:page].to_i : 1

    contacts = current_user.contacts
    contacts = contacts.search(params[:search]) if params[:search].present?

    contacts = case params[:order_by]
    when "name"
        contacts.order(name: params[:order_direction] || :asc)
    when "email"
        contacts.order(email: params[:order_direction] || :asc)
    when "visits"
        contacts.left_joins(:visits)
               .group(:id)
               .order("COUNT(visits.id) #{params[:order_direction] || 'desc'}")
    else
        contacts.order(created_at: params[:order_direction] || :desc)
    end

    @pagy, @contacts = pagy_countless(contacts, items: items_per_page, page: page)

    respond_to do |format|
      format.html
      format.turbo_stream if params[:page]
    end
  end

  def new
    @contact = current_user.contacts.build
  end

  def create
    @contact = current_user.contacts.build(contact_params_without_avatar)
    if @contact.save
      if params[:contact][:avatar].present?
        ImageHandlingService.process_images(@contact, params, compress: true)
      end
      redirect_to contact_path(id: @contact.id, locale: I18n.locale),
                  notice: "Contact was successfully created."
    else
      Rails.logger.error "Failed to create contact: #{@contact.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @contact = current_user.contacts.includes(visits: [ :restaurant, :images, :contacts ]).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Attempted to access invalid contact #{params[:id]} for user #{current_user.id}"
    redirect_to contacts_path, alert: "Contact not found."
  end

  def edit
  end

  def update
    if @contact.update(contact_params_without_avatar)
      if params[:contact][:avatar].present?
        ImageHandlingService.process_images(@contact, params, compress: true)
      end
      redirect_to contacts_path, notice: "Contact was successfully updated."
    else
      Rails.logger.error "Failed to update contact: #{@contact.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @contact.destroy
      redirect_to contacts_path, notice: "Contact was successfully deleted."
    else
      Rails.logger.error "Failed to delete contact: #{@contact.errors.full_messages}"
      redirect_to contacts_path, alert: "Failed to delete contact."
    end
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "Attempted to access invalid contact #{params[:id]} for user #{current_user.id}"
      redirect_to contacts_path, alert: "Contact not found."
  end

  def contact_params_without_avatar
    params.require(:contact).permit(:name, :email, :city, :country, :phone, :notes)
  end
end
