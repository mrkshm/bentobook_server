class ImageUploadComponent < ViewComponent::Base
    def initialize(form, imageable, template = nil)
      @form = form
      @imageable = imageable
      @template = template
    end
  
    private
  
    attr_reader :form, :imageable, :template
  end