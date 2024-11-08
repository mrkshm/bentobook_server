module Api
  module V1
    class ImagesController < Api::V1::BaseController
      include ImageablePermissions
      
      before_action :set_imageable
      before_action :set_image, only: [:destroy]
      before_action :check_permission

      def create
        @image = @imageable.images.new(image_params)
        
        if @image.save
          Rails.logger.info "Image successfully created for #{@imageable.class} #{@imageable.id}"
          render json: {
            message: 'Image uploaded successfully',
            image: image_response(@image)
          }, status: :created
        else
          handle_error('Failed to create image')
        end
      end

      def destroy
        if @image.destroy
          render json: { message: 'Image deleted successfully' }, status: :ok
        else
          handle_error('Failed to delete image')
        end
      end

      private

      def set_imageable
        @imageable = find_imageable
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Resource not found'] }, status: :not_found
      end

      def find_imageable
        params.each do |name, value|
          if name =~ /(.+)_id$/
            model = $1.classify.constantize
            return model.find(value)
          end
        end
        nil
      end

      def set_image
        @image = @imageable.images.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Image not found'] }, status: :not_found
      end

      def check_permission
        unless current_user_can_modify_imageable?(@imageable)
          Rails.logger.warn "User #{current_user.id} attempted to modify image for #{@imageable.class} #{@imageable.id} without permission"
          render json: { errors: ['Permission denied'] }, status: :forbidden
        end
      end

      def image_params
        { file: params[:file] }
      end

      def image_response(image)
        {
          id: image.id,
          url: rails_blob_url(image.file),
          filename: image.file.filename.to_s,
          content_type: image.file.content_type
        }
      end

      def handle_error(message)
        Rails.logger.error "#{message}: #{@image.errors.full_messages}"
        render json: { 
          errors: @image.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end