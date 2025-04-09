require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  let(:organization) { create(:organization) }
  let(:contact) { create(:contact) }
  let(:user) { create(:user, organization: organization) }

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

    # Attach directly to organization
    organization.avatar_medium.attach(
      io: file.open,
      filename: "avatar_medium.jpg",
      content_type: "image/jpeg"
    )

    organization.avatar_thumbnail.attach(
      io: file.open,
      filename: "avatar_thumbnail.jpg",
      content_type: "image/jpeg"
    )

    render_inline(AvatarComponent.new(organization: organization))
    expect(page).to have_css("img.rounded-full")
  end

  it "renders initials when no avatar is attached" do
    organization.update(name: "Sample Organization")
    render_inline(AvatarComponent.new(organization: organization))
    expect(page).to have_css("div", text: "SO")
  end

  it "renders user icon when no avatar is attached and placeholder_type is :icon" do
    render_inline(AvatarComponent.new(organization: organization, placeholder_type: :icon))
    expect(page).to have_css("svg")
  end

  it "applies the correct size class" do
    render_inline(AvatarComponent.new(organization: organization, size: :lg))
    expect(page).to have_css("div.size-12")
  end

  it "applies the default size class when an invalid size is provided" do
    render_inline(AvatarComponent.new(organization: organization, size: :invalid))
    expect(page).to have_css("div.size-10")
  end

  it "works with a Contact object" do
    contact = create(:contact, name: "Jane Smith")
    render_inline(AvatarComponent.new(contact: contact))
    expect(page).to have_css("div", text: "JS")
  end

  it "applies the small size class" do
    render_inline(AvatarComponent.new(organization: organization, size: :sm))
    expect(page).to have_css("div.size-8")
  end

  it "renders with tooltip when provided" do
    render_inline(AvatarComponent.new(organization: organization, tooltip: "Organization Profile"))

    expect(page).to have_css("div.tooltip.tooltip-top")
    expect(page).to have_css("div[data-tip='Organization Profile']")
    expect(page).to have_css("div.z-50")
  end

  it "renders without tooltip wrapper when tooltip is nil" do
    render_inline(AvatarComponent.new(organization: organization))

    expect(page).not_to have_css("div.tooltip")
  end

  describe "variant size mapping" do
    before do
      # Create and attach avatar directly
      file = fixture_file_upload(
        Rails.root.join("spec", "fixtures", "avatar.jpg"),
        "image/jpeg"
      )

      # Attach directly to organization
      organization.avatar_medium.attach(
        io: file.open,
        filename: "avatar_medium.jpg",
        content_type: "image/jpeg"
      )

      organization.avatar_thumbnail.attach(
        io: file.open,
        filename: "avatar_thumbnail.jpg",
        content_type: "image/jpeg"
      )
    end

    it "maps :small size to :thumbnail variant" do
      component = AvatarComponent.new(organization: organization, size: :sm)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the thumbnail for small sizes
      expect(organization.avatar_thumbnail).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "maps :large size to :medium variant" do
      component = AvatarComponent.new(organization: organization, size: :lg)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the medium for large sizes
      expect(organization.avatar_medium).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "uses :medium variant for default size" do
      component = AvatarComponent.new(organization: organization)
      render_inline(component)
      expect(page).to have_css("img.rounded-full")
      # The component should use the medium for default size
      expect(organization.avatar_medium).to receive(:blob).at_least(:once).and_call_original
      component.send(:render_avatar)
    end

    it "applies rounded-full class to the image" do
      render_inline(AvatarComponent.new(organization: organization))
      expect(page).to have_css("img.rounded-full")
    end
  end

  describe "user parameter handling" do
    it "uses the user's organization for avatar when provided" do
      # Create the organization first
      organization = create(:organization, name: "Test Org")
      # Create user without automatic organization creation
      user = create(:user)
      # Create membership to associate user with organization
      create(:membership, user: user, organization: organization)

      render_inline(AvatarComponent.new(user: user))
      expect(page).to have_css("div", text: "TO")
    end
  end

  describe "avatar name resolution" do
    it "uses name when available" do
      object_with_name = double("ObjectWithName")
      allow(object_with_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_with_name).to receive(:respond_to?).with(:name).and_return(true)
      allow(object_with_name).to receive(:name).and_return("Regular Name")

      component = AvatarComponent.new(organization: object_with_name)
      render_inline(component)
      expect(page).to have_css("div", text: "RN")
    end

    it "falls back to display_name when name is not available" do
      object_with_display_name = double("ObjectWithDisplayName")
      allow(object_with_display_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:name).and_return(false)
      allow(object_with_display_name).to receive(:respond_to?).with(:display_name).and_return(true)
      allow(object_with_display_name).to receive(:display_name).and_return("Display Name")

      component = AvatarComponent.new(organization: object_with_display_name)
      render_inline(component)
      expect(page).to have_css("div", text: "DN")
    end

    it "falls back to username when name and display_name are not available" do
      object_with_username = double("ObjectWithUsername")
      allow(object_with_username).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_with_username).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_with_username).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_with_username).to receive(:respond_to?).with(:name).and_return(false)
      allow(object_with_username).to receive(:respond_to?).with(:username).and_return(true)
      allow(object_with_username).to receive(:username).and_return("username123")
      allow(object_with_username).to receive(:username).and_return("username123")

      component = AvatarComponent.new(organization: object_with_username)
      # Access the private method directly to check the initials logic
      expect(component.send(:initials)).to eq("US")
      render_inline(component)
      expect(page).to have_css("div", text: "US")
    end

    it "uses fallback 'Unknown' when no name methods are available" do
      object_without_name = double("ObjectWithoutName")
      allow(object_without_name).to receive(:respond_to?).with(:avatar_medium).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:avatar_thumbnail).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:display_name).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:name).and_return(false)
      allow(object_without_name).to receive(:respond_to?).with(:username).and_return(false)

      component = AvatarComponent.new(organization: object_without_name)
      render_inline(component)
      expect(page).to have_css("div", text: "UN")
    end
  end

  describe "entity specific tests" do
    it "works with organization's name" do
      # Test with a real organization
      organization = create(:organization, name: "Org LLC", username: "cool_org")
      # The test name was misleading - we're now using name first, not display_name

      # Fix the test to have simpler expectations
      component = AvatarComponent.new(organization: organization)
      # Verify the actual initials method returns what we expect
      expect(component.send(:initials)).to eq("OL")
      render_inline(component)
      expect(page).to have_css("div", text: "OL")
    end

    it "works with contact's name" do
      contact = create(:contact, name: "John Doe")
      component = AvatarComponent.new(contact: contact)
      render_inline(component)
      expect(page).to have_css("div", text: "JD")
    end
  end
end
