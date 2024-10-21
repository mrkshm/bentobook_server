module Api
    module V1
      class ContactsController < Api::V1::BaseController
        include Pagy::Backend 
        before_action :set_contact, only: [:show, :update, :destroy]

        # GET /api/v1/contacts
        def index
          @pagy, @contacts = pagy(current_user.contacts.order(created_at: :desc))
          render json: {
            contacts: @contacts.map { |contact| ContactSerializer.new(contact).serializable_hash },
            pagination: pagy_metadata(@pagy)
          }, status: :ok
        end

        # GET /api/v1/contacts/:id
        def show
          render json: ContactSerializer.new(@contact).serialize
        end

        # POST /api/v1/contacts
        def create
          @contact = current_user.contacts.build(contact_params)
          if @contact.save
            render json: ContactSerializer.new(@contact).serialize, status: :created
          else
            render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # PATCH/PUT /api/v1/contacts/:id
        def update
          if @contact.update(contact_params)
            render json: ContactSerializer.new(@contact).serialize
          else
            render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/contacts/:id
        def destroy
          @contact.destroy
          head :no_content
        end

        private

        def set_contact
          @contact = current_user.contacts.find(params[:id])
        end

        def contact_params
          params.require(:contact).permit(:name, :email, :city, :country, :phone, :notes, :avatar)
        end
      end
    end
  end
