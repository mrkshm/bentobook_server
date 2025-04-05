# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  SIZES = {
    xs: "size-6",    # 24px
    sm: "size-8",    # 32px
    md: "size-10",   # 40px
    lg: "size-12",   # 48px
    xl: "size-14"    # 56px
  }.freeze

  def initialize(profile: nil, text: "", size: :md)
    @profile = profile
    @text = text.to_s  # Convert nil to empty string immediately
    @size = size
  end

  def call
    wrapper_classes = [ "inline-block", SIZES[@size], "rounded-full" ]
    wrapper_classes << "bg-surface-100" unless has_avatar?

    content_tag :div, class: wrapper_classes.join(" ") do
      if has_avatar?
        # Use thumbnail for small sizes, medium for larger ones
        avatar = %i[xs sm md].include?(@size) ? @profile.avatar_thumbnail : @profile.avatar_medium
        # Add HTML comment with image size info before the image tag
        comment = "<!-- Avatar: #{avatar.blob.filename} (#{ActiveSupport::NumberHelper.number_to_human_size(avatar.blob.byte_size)}) -->"
        (comment + image_tag(avatar,
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

  def has_avatar?
    @profile&.avatar_medium&.attached? && @profile&.avatar_thumbnail&.attached?
  end

  def initials
    @text.strip[0, 2].upcase.presence || "??"
  end
end
