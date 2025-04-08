# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  SIZES = {
    xs: "size-6",    # 24px
    sm: "size-8",    # 32px
    md: "size-10",   # 40px
    lg: "size-12",   # 48px
    xl: "size-14"    # 56px
  }.freeze

  def initialize(profile: nil, user: nil, text: "", size: :md, placeholder_type: :initials, tooltip: nil)
    @profile = profile || (user.respond_to?(:profile) ? user.profile : user)
    @text = text.to_s  # Convert nil to empty string immediately
    @size = size.nil? ? :md : size.to_sym
    @placeholder_type = placeholder_type
    @tooltip = tooltip
  end

  def call
    wrapper_classes = [ "inline-block", SIZES[@size] || SIZES[:md], "rounded-full" ]
    wrapper_classes << "bg-surface-100" unless has_avatar?

    content = if has_avatar?
      render_avatar
    else
      render_placeholder
    end

    if @tooltip.present?
      content_tag :div, content, class: "tooltip tooltip-top z-50", data: { tip: @tooltip }
    else
      content
    end
  end

  private

  def has_avatar?
    @profile&.respond_to?(:avatar_medium) &&
    @profile&.respond_to?(:avatar_thumbnail) &&
    @profile&.avatar_medium&.attached? &&
    @profile&.avatar_thumbnail&.attached?
  end

  def render_avatar
    wrapper_classes = [ "inline-block", SIZES[@size] || SIZES[:md], "rounded-full" ]

    content_tag :div, class: wrapper_classes.join(" ") do
      # Use thumbnail for small sizes, medium for larger ones
      avatar = %i[xs sm].include?(@size) ? @profile.avatar_thumbnail : @profile.avatar_medium
      # Add HTML comment with image size info before the image tag
      comment = "<!-- Avatar: #{avatar.blob.filename} (#{ActiveSupport::NumberHelper.number_to_human_size(avatar.blob.byte_size)}) -->"
      (comment + image_tag(avatar,
        class: "rounded-full object-cover w-full h-full",
        alt: resolve_name || "Avatar")).html_safe
    end
  end

  def render_placeholder
    wrapper_classes = [ "inline-block", SIZES[@size] || SIZES[:md], "rounded-full", "bg-surface-100" ]

    content_tag :div, class: wrapper_classes.join(" ") do
      if @placeholder_type == :icon
        render_icon
      else
        render_initials
      end
    end
  end

  def render_initials
    content_tag :div,
               initials,
               class: "w-full h-full rounded-full flex items-center justify-center
                      bg-surface-100 text-surface-600 text-sm"
  end

  def render_icon
    content_tag :div, class: "w-full h-full rounded-full flex items-center justify-center
                            bg-surface-100 text-surface-600" do
      # Create SVG with proper nesting
      tag.svg(xmlns: "http://www.w3.org/2000/svg",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke: "currentColor",
              class: "w-1/2 h-1/2") do
        concat tag.path(d: "M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z")
        concat tag.rect(width: "4", height: "6", x: "2", y: "9")
        concat tag.circle(r: "3", cx: "9", cy: "3")
      end
    end
  end

  def initials
    text = @text.presence || resolve_name.to_s

    # Special handling for "Unknown"
    return "UN" if text == "Unknown"
    return "??" if text.blank?

    # Get first letters of each word, up to 2 letters
    text.split.map(&:first).join("")[0, 2].upcase
  end

  def resolve_name
    if @profile.respond_to?(:display_name) && @profile.display_name.present?
      @profile.display_name
    elsif @profile.respond_to?(:name) && @profile.name.present?
      @profile.name
    elsif @profile.respond_to?(:full_name) && @profile.full_name.present?
      @profile.full_name
    else
      "Unknown"
    end
  end
end
