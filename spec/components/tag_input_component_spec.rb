require 'rails_helper'

RSpec.describe TagInputComponent, type: :component do
  let(:tags) { ['ruby', 'rails', 'javascript'] }
  let(:input_name) { 'custom_tag_list' }
  let(:component) { described_class.new(tags: tags, input_name: input_name) }

  it 'renders the component container' do
    render_inline(component)
    expect(page).to have_css('div[data-controller="tag-input"]')
  end

  it 'renders the tag list container' do
    render_inline(component)
    expect(page).to have_css('div[data-tag-input-target="tagList"]')
  end

  it 'renders the input field' do
    render_inline(component)
    expect(page).to have_css('input[data-tag-input-target="input"]')
  end

  it 'renders the suggestions container' do
    render_inline(component)
    expect(page).to have_css('div[data-tag-input-target="suggestions"]')
  end

  it 'renders the hidden input with correct name and value' do
    render_inline(component)
    expect(page).to have_css("input[type='hidden'][name='#{input_name}'][value='#{tags.join(',')}'][data-tag-input-target='hiddenInput']", visible: false)
  end

  it 'sets correct data actions on the input field' do
    render_inline(component)
    expect(page).to have_css('input[data-action="keydown->tag-input#handleKeyDown input->tag-input#filterSuggestions"]')
  end

  context 'with no tags' do
    let(:tags) { [] }

    it 'renders an empty hidden input' do
      render_inline(component)
      expect(page).to have_css("input[type='hidden'][value='']", visible: false)
    end
  end

  context 'with custom input name' do
    let(:input_name) { 'custom_tags' }

    it 'uses the custom input name for the hidden input' do
      render_inline(component)
      expect(page).to have_css("input[type='hidden'][name='custom_tags']", visible: false)
    end
  end

  describe 'accessibility' do
    it 'has a placeholder for the input field' do
      render_inline(component)
      expect(page).to have_css('input[placeholder="Add Tags..."]')
    end
  end

  describe '#tag_list' do
    context 'with multiple tags' do
      let(:tags) { ['ruby', 'rails', 'javascript'] }
      it 'joins tags with commas' do
        render_inline(described_class.new(tags: tags))
        expect(page).to have_css("input[type='hidden'][value='ruby,rails,javascript']", visible: false)
      end
    end

    context 'with a single tag' do
      let(:tags) { ['ruby'] }
      it 'returns the single tag' do
        render_inline(described_class.new(tags: tags))
        expect(page).to have_css("input[type='hidden'][value='ruby']", visible: false)
      end
    end

    context 'with no tags' do
      let(:tags) { [] }
      it 'returns an empty string' do
        render_inline(described_class.new(tags: tags))
        expect(page).to have_css("input[type='hidden'][value='']", visible: false)
      end
    end
  end
end
