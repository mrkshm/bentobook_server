require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  let(:user) { create(:user, :with_profile) }
  let(:profile) { user.profile }

  # Set up ActiveStorage URL options for tests
  before do
    ActiveStorage::Current.url_options = { host: "example.com" }
  end

  it "renders an img tag when avatar is attached" do
    # Create and attach avatar directly
    file = fixture_file_upload(
      Rails.root.join("spec", "fixtures", "avatar.jpg"),
      "image/jpeg"
    )
    
    # Attach directly to avoid using PreprocessAvatarService
    profile.avatar_medium.attach(
      io: file.open,
      filename: "avatar_medium.jpg",
      content_type: "image/jpeg"
    )
    
    profile.avatar_thumbnail.attach(
      io: file.open,
      filename: "avatar_thumbnail.jpg",
      content_type: "image/jpeg"
    )
    
    render_inline(AvatarComponent.new(profile: profile))
    expect(page).to have_css("img.rounded-full")
  end

  it "renders initials when no avatar is attached" do
    profile.update(username: nil, first_name: "User", last_name: "Sample")
    render_inline(AvatarComponent.new(profile: profile))
    expect(page).to have_css("div", text: "US")
  end

  it "renders user icon when no avatar is attached and placeholder_type is :icon" do
    render_inline(AvatarComponent.new(profile: profile, placeholder_type: :icon))
    expect(page).to have_css("svg")
  end

  it "applies the correct size class" do
    render_inline(AvatarComponent.new(profile: profile, size: :lg))
    expect(page).to have_css("div.size-12")
  end

  it "applies the default size class when an invalid size is provided" do
    render_inline(AvatarComponent.new(profile: profile, size: :invalid))
    expect(page).to have_css("div.size-10")
  end

  it "works with a Contact object" do
    contact = create(:contact, name: "Jane Smith")
    render_inline(AvatarComponent.new(user: contact))
    expect(page).to have_css("div", text: "JS")
  end

  it "applies the small size class" do
    render_inline(AvatarComponent.new(profile: profile, size: :sm))
    expect(page).to have_css("div.size-8")
  end

  it "renders with tooltip when provided" do
    render_inline(AvatarComponent.new(profile: profile, tooltip: "User Profile"))
    
    expect(page).to have_css("div.tooltip.tooltip-top")
    expect(page).to have_css("div[data-tip='User Profile']")
    expect(page).to have_css("div.z-50")
  end

  it "renders without tooltip wrapper when tooltip is nil" do
    render_inline(AvatarComponent.new(profile: profile))
    
    expect(page).not_to have_css("div.tooltip")
  end

  describe "variant size mapping" do
    before do
      # Create and attach avatar directly
      file = fixture_file_upload(
        Rails.root.join("spec", "fixtures", "avatar.jpg"),
        "image/jpeg"
      )
      
      # Attach directly to avoid using PreprocessAvatarService
      profile.avatar_medium.attach(
        io: file.open,
        filename: "avatar_medium.jpg",
        content_type: "image/jpeg"
      )
      
      profile.avatar_thumbnail.attach(
        io: file.open,
        filename: "avatar_thumbnail.jpg",
        content_type: "image/jpeg"
      )
    end

    it "maps :small size to :thumbnail variant" do
      component = AvatarComponent.new(profile: profile, size: :sm)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the thumbnail for small sizes
      expect(profile.avatar_thumbnail).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "maps :large size to :medium variant" do
      component = AvatarComponent.new(profile: profile, size: :lg)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the medium for large sizes
      expect(profile.avatar_medium).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "uses :medium variant for default size" do
      component = AvatarComponent.new(profile: profile)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the medium for default size
      expect(profile.avatar_medium).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "applies rounded-full class to the image" do
      render_inline(AvatarComponent.new(profile: profile))
      expect(page).to have_css("img.rounded-full")
    end
  end

  describe "avatar name resolution" do
    it "uses display_name when available" do
      object_with_display_name = double("ObjectWithDisplayName")
      allow(object_with_display_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:display_name).and_return(true)
      allow(object_with_display_name).to receive(:display_name).and_return("Display Name")

      component = AvatarComponent.new(profile: object_with_display_name)
      render_inline(component)
      expect(page).to have_css("div", text: "DN")
    end

    it "falls back to name when display_name is not available" do
      object_with_name = double("ObjectWithName")
      allow(object_with_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:name).and_return(true)
      allow(object_with_name).to receive(:name).and_return("Regular Name")

      component = AvatarComponent.new(profile: object_with_name)
      render_inline(component)
      expect(page).to have_css("div", text: "RN")
    end

    it "uses fallback 'Unknown' when no name methods are available" do
      object_without_name = double("ObjectWithoutName")
      allow(object_without_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:name).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:full_name).and_return(false)

      component = AvatarComponent.new(profile: object_without_name)
      render_inline(component)
      expect(page).to have_css("div", text: "UN")
    end
  end
end
