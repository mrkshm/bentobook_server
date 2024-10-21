module Api
  module V1
    class BaseController < ApiController
      include ApiControllerConcern
      include ApiErrorHandlerConcern
      include Pagy::Backend
    end
  end
end
