# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  SIZES = {
    xs: "size-6",    # 24px
    sm: "size-8",    # 32px
    md: "size-10",   # 40px
    lg: "size-12",   # 48px
    xl: "size-14"    # 56px
  }.freeze

  def initialize(image: nil, text: "", size: :md)
    @image = image
    @text = text.to_s  # Convert nil to empty string immediately
    @size = size
  end

  def call
    wrapper_classes = [ "inline-block", SIZES[@size], "rounded-full" ]
    wrapper_classes << "bg-surface-100" unless @image&.attached?

    content_tag :div, class: wrapper_classes.join(" ") do
      if @image&.attached?
        # Add HTML comment with image size info before the image tag
        comment = "<!-- Avatar: #{@image.blob.filename} (#{ActiveSupport::NumberHelper.number_to_human_size(@image.blob.byte_size)}) -->"
        (comment + image_tag(@image,
          class: "rounded-full object-cover w-full h-full",
          alt: @text.presence || "Avatar")).html_safe
      else
        content_tag :div,
                   initials,
                   class: "w-full h-full rounded-full flex items-center justify-center
                          bg-surface-100 text-surface-600 text-sm"
      end
    end
  end

  private

  def initials
    @text.strip[0, 2].upcase.presence || "??"
  end
end
