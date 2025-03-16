import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenInput", "tagList", "suggestions"]
  static values = { availableTags: Array }

  connect() {
    this.tags = new Set(this.hiddenInputTarget.value.split(',').map(tag => tag.trim()).filter(Boolean))
    this.renderTags()
  }

  handleKeyDown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.addTag()
    }
  }

  addTag() {
    const tag = this.inputTarget.value.trim()
    if (tag && !this.tags.has(tag)) {
      this.tags.add(tag)
      this.renderTags()
      this.inputTarget.value = ""
      this.updateHiddenInput()
    }
  }

  removeTag(event) {
    const tag = event.target.closest('.badge').dataset.tag
    this.tags.delete(tag)
    this.renderTags()
    this.updateHiddenInput()
  }

  renderTags() {
    this.tagListTarget.innerHTML = Array.from(this.tags).map(tag => `
      <span class="badge badge-outline gap-2 py-4 px-4" data-tag="${tag}">
        ${tag}
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-4 h-4 stroke-current cursor-pointer" data-action="click->tag-input#removeTag"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
      </span>
    `).join('')
  }

  updateHiddenInput() {
    this.hiddenInputTarget.value = Array.from(this.tags).join(',')
  }

  filterSuggestions() {
    const input = this.inputTarget.value.toLowerCase()
    if (input.length < 2) {
      this.suggestionsTarget.innerHTML = ''
      return
    }
    const suggestions = this.availableTagsValue.filter(tag => 
      tag.toLowerCase().startsWith(input) && !this.tags.has(tag)
    ).slice(0, 5)
    this.suggestionsTarget.innerHTML = suggestions.map(tag => `
      <div class="cursor-pointer p-1 hover:bg-gray-100" data-action="click->tag-input#selectSuggestion">${tag}</div>
    `).join('')
  }

  selectSuggestion(event) {
    this.inputTarget.value = event.target.textContent
    this.addTag()
    this.suggestionsTarget.innerHTML = ''
  }
}
