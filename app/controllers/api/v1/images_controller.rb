module Api
    module V1
      class ImagesController < Api::V1::BaseController
        before_action :set_imageable
        before_action :set_image, only: [:destroy]
        before_action :check_permission, only: [:create, :destroy]

        def create
          @image = @imageable.images.new(image_params)
          if @image.save
            Rails.logger.info "Image successfully created for #{@imageable.class} #{@imageable.id}"
            render json: { message: 'Image uploaded successfully', image: image_url(@image) }, status: :created
          else
            Rails.logger.error "Failed to create image: #{@image.errors.full_messages}"
            render json: { errors: @image.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          if @image.destroy
            render json: { message: 'Image deleted successfully' }, status: :ok
          else
            render json: { errors: @image.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def set_imageable
          resource, id = request.path.split('/')[3, 2]
          @imageable = resource.singularize.classify.constantize.find(id)
        end

        def set_image
          @image = @imageable.images.find(params[:id])
        end

        def check_permission
          unless current_user_can_modify_image?
            Rails.logger.warn "User #{current_user.id} attempted to modify image for #{@imageable.class} #{@imageable.id} without permission"
            render json: { errors: ['Permission denied'] }, status: :forbidden
          end
        end

        def current_user_can_modify_image?
          case @imageable
          when Visit, Contact, Restaurant
            @imageable.user == current_user
          else
            false
          end
        end

        def image_params
          params.require(:image).permit(:file)
        end

        def image_url(image)
          rails_blob_url(image.file)
        end
      end
    end
  end