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
    let(:model_name) do
      double("ActiveModel::Name").tap do |name|
        allow(name).to receive(:param_key).and_return("blob")
        allow(name).to receive(:name).and_return("ActiveStorage::Blob")
      end
    end

    let(:mock_blob) do
      double("ActiveStorage::Blob").tap do |blob|
        allow(blob).to receive(:signed_id).and_return("blob_123")
        allow(blob).to receive(:filename).and_return("test.jpg")
        allow(blob).to receive(:content_type).and_return("image/jpeg")
        allow(blob).to receive(:to_i).and_return(123)
        allow(blob).to receive(:to_model).and_return(blob)
        allow(blob).to receive(:model_name).and_return(model_name)
      end
    end

    let(:mock_variant) do
      double("ActiveStorage::Variant").tap do |variant|
        allow(variant).to receive(:processed).and_return(true)
        allow(variant).to receive(:url).and_return("https://example.com/variant.jpg")
        allow(variant).to receive(:to_model).and_return(variant)
        allow(variant).to receive(:model_name).and_return(model_name)
        allow(variant).to receive(:filename).and_return("test.jpg")
        allow(variant).to receive(:blob).and_return(mock_blob)
        allow(variant).to receive(:representation).and_return(variant)
        allow(variant).to receive(:variation).and_return(variant)
        allow(variant).to receive(:key).and_return("variant_key_123")
      end
    end

    let(:mock_avatar) do
      double("ActiveStorage::Attachment").tap do |avatar|
        allow(avatar).to receive(:attached?).and_return(true)
        allow(avatar).to receive(:blob).and_return(mock_blob)
        allow(avatar).to receive(:variant).and_return(mock_variant)
        allow(avatar).to receive(:url).and_return("https://example.com/test.jpg")
      end
    end

    let(:mock_profile) do
      double("Profile").tap do |profile|
        allow(profile).to receive(:is_a?).with(Contact).and_return(false)
        allow(profile).to receive(:avatar).and_return(mock_avatar)
        allow(profile).to receive(:respond_to?).with(:avatar).and_return(true)
      end
    end

    let(:mock_user) do
      double("User").tap do |user|
        allow(user).to receive(:is_a?).with(User).and_return(true)
        allow(user).to receive(:profile).and_return(mock_profile)
      end
    end

    before do
      allow(mock_avatar).to receive(:variant) do |options|
        @last_variant_options = options
        mock_variant
      end
    end

    it "maps :small size to :thumbnail variant" do
      render_inline(AvatarComponent.new(user: mock_user, size: :small))
      expect(@last_variant_options).to eq(
        resize_to_fill: [100, 100],
        format: :webp,
        saver: { quality: 80 }
      )
    end

    it "maps :large size to :medium variant" do
      render_inline(AvatarComponent.new(user: mock_user, size: :large))
      expect(@last_variant_options).to eq(
        resize_to_limit: [600, 400],
        format: :webp,
        saver: { quality: 80 }
      )
    end

    it "uses :medium variant for default size" do
      render_inline(AvatarComponent.new(user: mock_user))
      expect(@last_variant_options).to eq(
        resize_to_limit: [600, 400],
        format: :webp,
        saver: { quality: 80 }
      )
    end

    it "applies rounded-full class to the image" do
      render_inline(AvatarComponent.new(user: mock_user))
      expect(page).to have_css("img.rounded-full")
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
