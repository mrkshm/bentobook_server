module Api
  module V1
    class ContactsController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_contact, only: [ :show, :update, :destroy ]

      def index
        contacts = current_user.contacts.order(created_at: :desc)
        pagy, records = pagy(contacts)

        render json: ContactSerializer.render_collection(records, pagy: pagy)
      rescue Pagy::OverflowError
        last_page = (contacts.count.to_f / Pagy::DEFAULT[:items]).ceil
        pagy, _ = pagy(contacts, page: last_page)
        render json: ContactSerializer.render_collection([], pagy: pagy), status: :ok
      rescue StandardError => e
        Rails.logger.error "Index error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def show
        _includes = params[:include].to_s.split(",")

        render json: ContactSerializer.render_success(@contact)
      rescue StandardError => e
        Rails.logger.error "Show error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def create
        contact = nil

        Contact.transaction do
          contact = current_user.contacts.build(contact_params_without_avatar)
          contact.save!

          if params.dig(:contact, :avatar).present?
            Rails.logger.info "Processing avatar with ImageHandlingService"
            begin
              result = ImageHandlingService.process_images(contact, params, compress: true)
              unless result[:success]
                contact.errors.add(:avatar, result[:message])
                raise ActiveRecord::RecordInvalid.new(contact)
              end
            rescue Vips::Error => e
              contact.errors.add(:avatar, "must be a valid image file")
              raise ActiveRecord::RecordInvalid.new(contact)
            end
          end
        end

        render json: ContactSerializer.render_success(contact), status: :created
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Validation error: #{e.record.errors.full_messages.join(', ')}"
        errors = e.record.errors.map { |error| ActiveModel::Error.new(e.record, error.attribute, error.message) }
        render json: ContactSerializer.render_error(errors), status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Create error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def update
        Contact.transaction do
          @contact.update!(contact_params_without_avatar)

          if params.dig(:contact, :avatar).present?
            Rails.logger.info "Processing avatar with ImageHandlingService"
            begin
              result = ImageHandlingService.process_images(@contact, params, compress: true)
              unless result[:success]
                @contact.errors.add(:avatar, result[:message])
                raise ActiveRecord::RecordInvalid.new(@contact)
              end
            rescue Vips::Error => e
              @contact.errors.add(:avatar, "must be a valid image file")
              raise ActiveRecord::RecordInvalid.new(@contact)
            end
          end
        end

        render json: ContactSerializer.render_success(@contact)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Validation error: #{e.record.errors.full_messages.join(', ')}"
        errors = e.record.errors.map do |error|
          {
            code: "validation_error",
            detail: error.message,
            source: { pointer: "/data/attributes/#{error.attribute}" }
          }
        end
        render json: ContactSerializer.render_error(errors), status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Update error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ {
          code: "general_error",
          detail: e.message
        } ]), status: :internal_server_error
      end

      def destroy
        @contact.destroy!
        render json: { status: "success", meta: { timestamp: Time.current.iso8601 } }
      rescue StandardError => e
        Rails.logger.error "Destroy error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def search
        query = params[:query].to_s.strip
        contacts = current_user.contacts

        if query.present?
          contacts = contacts.search(query)
        end

        pagy, records = pagy(contacts.order(created_at: :desc))
        render json: ContactSerializer.render_collection(records, pagy: pagy)
      rescue StandardError => e
        Rails.logger.error "Search error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ContactSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      private

      def set_contact
        @contact = current_user.contacts.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: ContactSerializer.render_error([ "Contact not found" ]), status: :not_found
      end

      def contact_params_without_avatar
        params.require(:contact).permit(
          :name, :email, :city, :country,
          :phone, :notes
        )
      end
    end
  end
end
