class ImageUploadComponent < ViewComponent::Base
  def initialize(form, imageable, template = nil)
    @form = form
    @imageable = imageable
    @template = template
  end

  # Make sure these helper methods actually return HTML, not just delegate
  def url_for(attachment)
    return "#" unless template
    template.url_for(attachment)
  end

  def image_tag(url, options = {})
    return "<img src=\"#{url}\" class=\"#{options[:class]}\">".html_safe unless template
    template.image_tag(url, options)
  end

  private

  attr_reader :form, :imageable, :template
end
