class AvatarComponent < ViewComponent::Base
  def initialize(user:, size: :medium, placeholder_type: :initials, tooltip: nil)
    @user = user
    @profile = user.is_a?(User) ? user.profile : user
    @size = size
    @placeholder_type = placeholder_type
    @tooltip = tooltip
  end

  def call
    if @tooltip
      content_tag :div, class: "tooltip tooltip-top z-50", data: { tip: @tooltip } do
        avatar_content
      end
    else
      avatar_content
    end
  end

  private

  def avatar_content
    content_tag :div, class: "avatar #{'placeholder' unless has_avatar?}" do
      content_tag :div, class: avatar_classes do
        if has_avatar?
          avatar_image = @profile.is_a?(Contact) ? @profile.avatar : @profile.avatar
          render(S3ImageComponent.new(
            image: avatar_image,
            size: { width: avatar_size, height: avatar_size },
            format: :webp,
            quality: 75,
            fit: "cover",
            html_class: "rounded-full"
          ))
        else
          placeholder_content
        end
      end
    end
  end

  def has_avatar?
    if @profile.is_a?(Contact)
      @profile.avatar.attached?
    else
      @profile.respond_to?(:avatar) && @profile.avatar.attached?
    end
  end

  def avatar_classes
    classes = ["rounded-full"]
    classes << size_class
    classes << "bg-neutral text-neutral-content" unless has_avatar?
    classes.join(" ")
  end

  def size_class
    case @size
    when :small then "w-8 h-8"
    when :large then "w-24 h-24"
    else "w-24 h-24"
    end
  end

  def user_initials_class
    case @size
    when :small then "text-xl"
    when :large then "text-3xl"
    else "text-3xl"
    end
  end

  def placeholder_content
    if @placeholder_type == :initials
      content_tag :span, user_initials, class: user_initials_class
    else
      content_tag :svg, xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 20 20", fill: "currentColor", class: "w-1/2 h-1/2" do
        content_tag :path, nil, fill_rule: "evenodd", d: "M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z", clip_rule: "evenodd"
      end
    end
  end

  def user_initials
    name = avatar_name
    parts = name.split
    if parts.size >= 2
      parts.map(&:first).join[0,2].upcase
    else
      name[0,2].upcase
    end
  end

  def avatar_name
    if @profile.is_a?(Contact)
      @profile.name
    elsif @profile.respond_to?(:display_name)
      @profile.display_name
    elsif @profile.respond_to?(:name)
      @profile.name
    else
      fallback_name
    end
  end

  def fallback_name
    "Unknown"
  end

  def avatar_size
    case @size
    when :small then 32
    when :large then 96
    else 96
    end
  end
end
