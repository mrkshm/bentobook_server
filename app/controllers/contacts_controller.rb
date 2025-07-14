class ContactsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]

  def index
    items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 12
    page = params[:page].to_i.positive? ? params[:page].to_i : 1

    contacts = Current.organization.contacts
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
    @contact = Current.organization.contacts.build
  end

  def create
    @contact = Current.organization.contacts.build(contact_params_without_avatar)

    if @contact.save
      if params[:contact][:avatar].present?
        result = PreprocessAvatarService.call(params.dig(:contact, :avatar))
        if result[:success]
          @contact.avatar_medium.attach(result[:variants][:medium])
          @contact.avatar_thumbnail.attach(result[:variants][:thumbnail])
        else
          Rails.logger.error "Failed to process avatar: #{result[:error]}"
        end
      end
      Rails.logger.debug "Contact saved: #{@contact.inspect}"
      Rails.logger.debug "Generated path: #{contact_path(@contact.id, locale: I18n.locale)}"
      redirect_to contact_path(@contact.id, locale: I18n.locale), notice: t("contacts.success.creation")
    else
      Rails.logger.error "Failed to create contact: #{@contact.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @contact = Current.organization.contacts.includes(visits: [ :restaurant, :images, :contacts ]).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Attempted to access invalid contact #{params[:id]} for organization #{Current.organization.id}"
    redirect_to contacts_path, alert: t("contacts.error.not_found")
  end

  def edit
  end

  def update
    if @contact.update(contact_params_without_avatar)
      if params[:contact][:avatar].present?
        # Remove old avatars if they exist
        @contact.avatar_medium.purge if @contact.avatar_medium.attached?
        @contact.avatar_thumbnail.purge if @contact.avatar_thumbnail.attached?

        # Process and attach new variants
        result = PreprocessAvatarService.call(params.dig(:contact, :avatar))
        if result[:success]
          @contact.avatar_medium.attach(result[:variants][:medium])
          @contact.avatar_thumbnail.attach(result[:variants][:thumbnail])
        else
          Rails.logger.error "Failed to process avatar: #{result[:error]}"
        end
      end
      redirect_to contacts_path, notice: t("contacts.success.update")
    else
      Rails.logger.error "Failed to update contact: #{@contact.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @contact.destroy
      flash[:notice] = t("contacts.success.deletion")
      redirect_to contacts_path
    else
      Rails.logger.error "Failed to delete contact #{@contact.id} for organization #{Current.organization.id}"
      flash[:alert] = t("contacts.error.deletion")
      redirect_to contacts_path
    end
  end

  private

  def set_contact
    @contact = Current.organization.contacts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Attempted to access invalid contact #{params[:id]} for organization #{Current.organization.id}"
    redirect_to contacts_path, alert: t("contacts.error.not_found")
  end

  def contact_params_without_avatar
    params.require(:contact).permit(:name, :email, :city, :country, :phone, :notes)
  end
end
