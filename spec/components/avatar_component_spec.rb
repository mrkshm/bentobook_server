require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  let(:user) { create(:user, :with_profile) }
  let(:profile) { user.profile }

  it "renders an img tag when avatar is attached" do
    profile.avatar.attach(io: File.open(Rails.root.join("spec", "fixtures", "avatar.jpg")), filename: "avatar.jpg", content_type: "image/jpeg")
    render_inline(AvatarComponent.new(user: user))
    expect(page).to have_css("img[src*='avatar.jpg']")
  end

  it "renders initials when no avatar is attached" do
    profile.update(username: nil, first_name: "User", last_name: "Sample")
    render_inline(AvatarComponent.new(user: user))
    expected_initials = "US"
    rendered_content = page.text.strip
    expect(page).to have_css("span", text: expected_initials),
      "Expected to find initials '#{expected_initials}', but found '#{rendered_content}'"
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

  it "renders 'Unknown' when avatar_name cannot be determined" do
    allow_any_instance_of(AvatarComponent).to receive(:avatar_name).and_return("Unknown")
    render_inline(AvatarComponent.new(user: user))
    expect(page).to have_css("span", text: "UN")
  end

  it "handles single-word names (like usernames)" do
    profile.update(username: "johndoe", first_name: nil, last_name: nil)
    render_inline(AvatarComponent.new(user: user))
    expect(page).to have_css("span", text: "JO")
  end

  it "uses 'Unknown' when neither display_name nor name methods are available" do
    object_without_name = double("ObjectWithoutName")
    component = AvatarComponent.new(user: object_without_name)
    
    allow(object_without_name).to receive(:respond_to?).and_return(false)
    allow(object_without_name).to receive(:is_a?).with(User).and_return(false)
    
    render_inline(component)
    expect(page).to have_css("span", text: "UN")
  end
end
