require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  let(:user) { create(:user, :with_profile) }
  let(:profile) { user.profile }

  # Set up ActiveStorage URL options for tests
  before do
    ActiveStorage::Current.url_options = { host: "example.com" }
  end

  it "renders an img tag when avatar is attached" do
    profile.avatar.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "avatar.jpg")),
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    )
    
    render_inline(AvatarComponent.new(user: user))
    expect(page).to have_css("img.rounded-full")
  end

  it "renders initials when no avatar is attached" do
    profile.update(username: nil, first_name: "User", last_name: "Sample")
    render_inline(AvatarComponent.new(user: user))
    expect(page).to have_css("span", text: "US")
  end

  it "renders user icon when no avatar is attached and placeholder_type is :icon" do
    render_inline(AvatarComponent.new(user: user, placeholder_type: :icon))
    expect(page).to have_css("svg")
  end

  it "applies the correct size class" do
    render_inline(AvatarComponent.new(user: user, size: :large))
    expect(page).to have_css("div.w-24.h-24")
  end

  it "applies the default size class when an invalid size is provided" do
    render_inline(AvatarComponent.new(user: user, size: :invalid))
    expect(page).to have_css("div.w-24.h-24")
  end

  it "works with a Contact object" do
    contact = create(:contact, name: "Jane Smith")
    render_inline(AvatarComponent.new(user: contact))
    expect(page).to have_css("span", text: "JS")
  end

  it "applies the small size class" do
    render_inline(AvatarComponent.new(user: user, size: :small))
    expect(page).to have_css("div.w-8.h-8")
  end

  it "renders with tooltip when provided" do
    render_inline(AvatarComponent.new(user: user, tooltip: "User Profile"))
    
    expect(page).to have_css("div.tooltip.tooltip-top")
    expect(page).to have_css("div[data-tip='User Profile']")
    expect(page).to have_css("div.z-50")
  end

  it "renders without tooltip wrapper when tooltip is nil" do
    render_inline(AvatarComponent.new(user: user))
    
    expect(page).not_to have_css("div.tooltip")
    expect(page).to have_css("div.avatar") # Should render avatar directly
  end

  describe "variant size mapping" do
    before do
      profile.avatar.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "avatar.jpg")),
        filename: "avatar.jpg",
        content_type: "image/jpeg"
      )
      
      # Stub the render method to prevent actual rendering
      allow_any_instance_of(AvatarComponent).to receive(:render) do |_, component|
        # Store the component for verification
        @rendered_component = component
      end
    end

    it "maps :small size to :thumbnail variant" do
      render_inline(AvatarComponent.new(user: user, size: :small))
      
      expect(@rendered_component).to be_a(S3ImageComponent)
      expect(@rendered_component.size).to eq(:thumbnail)
      expect(@rendered_component.html_class).to eq("rounded-full")
      expect(@rendered_component.image).to eq(profile.avatar)
    end

    it "maps :large size to :medium variant" do
      render_inline(AvatarComponent.new(user: user, size: :large))
      
      expect(@rendered_component).to be_a(S3ImageComponent)
      expect(@rendered_component.size).to eq(:medium)
      expect(@rendered_component.html_class).to eq("rounded-full")
      expect(@rendered_component.image).to eq(profile.avatar)
    end

    it "uses :medium variant for default size" do
      render_inline(AvatarComponent.new(user: user))
      
      expect(@rendered_component).to be_a(S3ImageComponent)
      expect(@rendered_component.size).to eq(:medium)
      expect(@rendered_component.html_class).to eq("rounded-full")
      expect(@rendered_component.image).to eq(profile.avatar)
    end
  end

  describe "avatar name resolution" do
    it "uses display_name when available" do
      object_with_display_name = double("ObjectWithDisplayName")
      allow(object_with_display_name).to receive(:is_a?).with(anything).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:avatar).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:display_name).and_return(true)
      allow(object_with_display_name).to receive(:display_name).and_return("Display Name")

      component = AvatarComponent.new(user: object_with_display_name)
      render_inline(component)
      expect(page).to have_css("span", text: "DN")
    end

    it "falls back to name when display_name is not available" do
      object_with_name = double("ObjectWithName")
      allow(object_with_name).to receive(:is_a?).with(anything).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:avatar).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:name).and_return(true)
      allow(object_with_name).to receive(:name).and_return("Regular Name")

      component = AvatarComponent.new(user: object_with_name)
      render_inline(component)
      expect(page).to have_css("span", text: "RN")
    end

    it "uses fallback 'Unknown' when no name methods are available" do
      object_without_name = double("ObjectWithoutName")
      allow(object_without_name).to receive(:is_a?).with(anything).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:avatar).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:name).and_return(false)

      component = AvatarComponent.new(user: object_without_name)
      render_inline(component)
      expect(page).to have_css("span", text: "UN")
    end
  end
end
