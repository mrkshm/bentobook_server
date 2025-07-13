import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tagList", "suggestions", "hiddenInput", "form", "error", "suggestedTagsDisplay"]
  static values = { 
    availableTags: Array,
    currentTags: Array,
    maxTagLength: { type: Number, default: 50 }
  }

  connect() {
    this.originalTags = new Set(this.currentTagsValue || [])
    this.addedTags = new Set()
    this.removedTags = new Set()
    this.updateTagsDisplay()
    this.updateSuggestions()
    this.hideError()
  }

  // Simplified tag addition - handles both manual and suggested tags
  addTag(event) {
    if (event.type === "click" || (event.key === "Enter" && this.inputTarget.value.trim())) {
      event.preventDefault()
      
      const tag = (event.type === "click" ? event.currentTarget.dataset.tag : this.inputTarget.value.trim()).toLowerCase()
      
      if (!this.isValidTagLength(tag)) {
        this.showError(`Tags must be ${this.maxTagLengthValue} characters or less`)
        return
      }
      
      if (!this.hasTag(tag)) {
        this.addedTags.add(tag)
        this.removedTags.delete(tag) // In case it was previously removed
        
        this.hideError()
        this.updateTagsDisplay()
        this.updateSuggestions()
        this.clearInput()
      }
    }
  }

  clearInput() {
    this.inputTarget.value = ""
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.innerHTML = ""
    }
  }

  removeTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    
    this.originalTags.has(tag) ? this.removedTags.add(tag) : this.addedTags.delete(tag)
    
    this.hideError()
    this.updateTagsDisplay()
    this.updateSuggestions()
  }

  filterSuggestions() {
    const input = this.inputTarget.value.toLowerCase().trim()
    if (!this.hasSuggestionsTarget) return
    
    const currentTags = this.getCurrentTags()
    const suggestions = this.availableTagsValue
      .filter(tag => {
        const lowercasedTag = tag.toLowerCase();
        return !currentTags.has(lowercasedTag) && 
               lowercasedTag.includes(input) &&
               lowercasedTag !== input
      })
      .slice(0, 5)

    this.suggestionsTarget.innerHTML = input ? this.renderSuggestions(suggestions, input) : ""
  }

  async submitForm(event) {
    event.preventDefault()
    const submitButton = event.currentTarget
    submitButton.disabled = true
    submitButton.innerHTML = 'Saving...'
    
    try {
      this.hiddenInputTarget.value = JSON.stringify([...this.getCurrentTags()])
      
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method,
        body: new FormData(this.formTarget),
        headers: {
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      })
      
      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Failed to save tags")
      }
      
      // Handle successful response
      if (this.isNativeApp()) {
        // For native app, navigate back to restaurant show page
        window.Turbo.visit(this.formTarget.dataset.successUrl, { action: "replace" })
      } else {
        // For web app, handle Turbo Stream response
        const contentType = response.headers.get('Content-Type')
        if (contentType?.includes('text/vnd.turbo-stream.html')) {
          Turbo.renderStreamMessage(await response.text())
        }
      }
    } catch (error) {
      console.error("Error:", error)
      this.showError(error.message)
      submitButton.disabled = false
    }
  }

  cancelChanges(event) {
    if (event) event.preventDefault()
    this.addedTags.clear()
    this.removedTags.clear()
    this.hideError()
    this.updateTagsDisplay()
    this.updateSuggestions()
  }

  // Private methods
  getCurrentTags() {
    const tags = new Set([...this.originalTags])
    this.removedTags.forEach(tag => tags.delete(tag))
    this.addedTags.forEach(tag => tags.add(tag))
    return tags
  }

  hasTag(tag) {
    return this.getCurrentTags().has(tag.toLowerCase())
  }

  isValidTagLength(tag) {
    return tag.length > 0 && tag.length <= this.maxTagLengthValue
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('hidden')
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add('hidden')
    }
  }

  updateTagsDisplay() {
    if (!this.hasTagListTarget) return
    
    const tagElements = [...this.getCurrentTags()].map(tag => `
      <div class="inline-flex items-center bg-primary-100 text-primary-800 rounded-full px-3 py-1 text-sm font-medium mr-2 mb-2">
        <span>${tag}</span>
        <button type="button"
                class="ml-1 text-primary-600 hover:text-primary-800"
                data-action="click->tags--editor#removeTag"
                data-tag="${tag}">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `).join("")
    
    this.tagListTarget.innerHTML = tagElements
  }

  updateSuggestions() {
    if (!this.hasSuggestedTagsDisplayTarget) return

    const currentTags = this.getCurrentTags()
    const suggestedTags = this.availableTagsValue.filter(tag => !currentTags.has(tag.toLowerCase()))

    this.suggestedTagsDisplayTarget.innerHTML = this.renderSuggestedTags(suggestedTags)
  }

  renderSuggestedTags(tags) {
    return tags.map(tag => `
      <button type="button"
              data-tag="${tag}"
              data-action="click->tags--editor#addTag"
              class="inline-flex items-center bg-surface-100 text-surface-800 rounded-full px-3 py-1 text-sm font-medium hover:bg-surface-200 transition-colors">
        ${tag}
      </button>
    `).join("")
  }

  renderSuggestions(suggestions, input) {
    const suggestionElements = suggestions.map(tag => `
      <button type="button"
              class="block w-full text-left px-3 py-2 hover:bg-surface-100"
              data-action="click->tags--editor#addTag"
              data-tag="${tag}">
        ${tag}
      </button>
    `).join("")

    // Add current input as new tag option if valid
    if (input && this.isValidTagLength(input) && !this.hasTag(input)) {
      return suggestionElements + `
        <button type="button"
                class="block w-full text-left px-3 py-2 hover:bg-surface-100 font-medium"
                data-action="click->tags--editor#addTag"
                data-tag="${input}">
          Add "${input}"
        </button>
      `
    }

    return suggestionElements
  }

  isNativeApp() {
    return navigator.userAgent.includes("Turbo Native")
  }
}