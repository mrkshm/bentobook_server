# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  SIZES = {
    xs: "size-6",    # 24px
    sm: "size-8",    # 32px
    md: "size-10",   # 40px
    lg: "size-12",   # 48px
    xl: "size-14"    # 56px
  }.freeze

  def initialize(organization: nil, contact: nil, user: nil, text: "", size: :md, placeholder_type: :initials, tooltip: nil)
    # Fix how we retrieve the organization from a user
    @entity = organization || contact || (user && user.respond_to?(:memberships) ? user.organizations.first : nil)
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

  # Make initials method public for testing
  def initials
    text = @text.presence || resolve_name.to_s

    puts "Text for initials: '#{text}'"
    puts "Entity inspect: #{@entity.inspect}" if @entity
    puts "Text param: '#{@text}'"

    # Special handling for "Unknown"
    return "UN" if text == "Unknown"
    return "??" if text.blank?

    # Split by spaces
    words = text.split

    puts "Words split: #{words.inspect}"

    if words.length >= 2
      # Get first letters of first and second word
      result = (words[0][0] + words[1][0]).upcase
      puts "Multi-word result: #{result}"
      result
    else
      # For single word, take first two letters (or first letter twice if single letter)
      word = words[0]
      if word.length >= 2
        result = word[0..1].upcase
        puts "Single word result: #{result}"
        result
      else
        result = (word[0] * 2).upcase
        puts "Single letter result: #{result}"
        result
      end
    end
  end

  private

  def has_avatar?
    @entity&.respond_to?(:avatar_medium) &&
    @entity&.respond_to?(:avatar_thumbnail) &&
    @entity&.avatar_medium&.attached? &&
    @entity&.avatar_thumbnail&.attached?
  end

  def render_avatar
    wrapper_classes = [ "inline-block", SIZES[@size] || SIZES[:md], "rounded-full" ]

    content_tag :div, class: wrapper_classes.join(" ") do
      # Use thumbnail for small sizes, medium for larger ones
      avatar = %i[xs sm].include?(@size) ? @entity.avatar_thumbnail : @entity.avatar_medium
      # Add HTML comment with image size info before the image tag
      comment = "<!-- Avatar: #{avatar.blob.filename} (#{ActiveSupport::NumberHelper.number_to_human_size(avatar.blob.byte_size)}) -->"
      (comment + image_tag(avatar,
        class: "rounded-full object-cover w-full h-full",
        alt: resolve_name || "Avatar")).html_safe
    end
  end

  def render_placeholder
    wrapper_classes = [ "inline-block", SIZES[@size] || SIZES[:md], "rounded-full", "bg-surface-100" ]

    # Debug statement to help diagnose the issue
    puts "Rendering placeholder with initials: #{initials.inspect}"

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

  def resolve_name
    result = if @entity.respond_to?(:name) && @entity.name.present?
      @entity.name
    elsif @entity.respond_to?(:display_name) && @entity.display_name.present?
      @entity.display_name
    elsif @entity.respond_to?(:username) && @entity.username.present?
      @entity.username
    else
      "Unknown"
    end

    # Debug - print what attribute we're using
    from = if @entity.respond_to?(:name) && @entity.name == result
      "name"
    elsif @entity.respond_to?(:display_name) && @entity.display_name == result
      "display_name"
    elsif @entity.respond_to?(:username) && @entity.username == result
      "username"
    else
      "fallback"
    end
    puts "Using #{from} for name resolution: '#{result}'"

    result
  end
end
