class AvatarComponent < ViewComponent::Base
  def initialize(user:, size: :medium, placeholder_type: :initials)
    @user = user
    @profile = user.is_a?(User) ? user.profile : user
    @size = size
    @placeholder_type = placeholder_type
  end

  def call
    content_tag :div, class: "avatar #{'placeholder' unless has_avatar?}" do
      content_tag :div, class: avatar_classes do
        if has_avatar?
          image_tag @profile.avatar, alt: "Avatar of #{avatar_name}"
        else
          placeholder_content
        end
      end
    end
  end

  private

  def has_avatar?
    @profile.respond_to?(:avatar) && @profile.avatar.attached?
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
    when :medium then "w-12 h-12"
    when :large then "w-24 h-24"
    else "w-12 h-12"
    end
  end

  def placeholder_content
    if @placeholder_type == :initials
      content_tag :span, user_initials
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
    if @profile.respond_to?(:display_name)
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
end