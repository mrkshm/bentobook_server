import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tagList", "suggestions", "hiddenInput", "form", "error"]
  static values = { 
    availableTags: Array,
    currentTags: Array,
    maxTagLength: { type: Number, default: 50 }
  }

  connect() {
    // Initialize tags from the hidden input if available
    this.originalTags = new Set(this.currentTagsValue || [])
    this.addedTags = new Set()
    this.removedTags = new Set()
    
    // Update the UI to reflect current state
    this.updateTagsDisplay()
    this.updateSuggestions()
    
    // Hide error message initially
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add('hidden')
    }
  }

  // Add a new tag when Enter is pressed
  addTag(event) {
    if (event.key === "Enter" && this.inputTarget.value.trim() !== "") {
      event.preventDefault()
      
      const tag = this.inputTarget.value.trim().toLowerCase()
      
      // Validate tag length
      if (!this.isValidTagLength(tag)) {
        this.showError(`Tags must be ${this.maxTagLengthValue} characters or less`)
        return
      }
      
      if (this.isValidTag(tag) && !this.hasTag(tag)) {
        this.addedTags.add(tag)
        if (this.removedTags.has(tag)) {
          this.removedTags.delete(tag)
        }
        
        this.hideError()
        this.updateTagsDisplay()
        this.updateSuggestions()
        this.inputTarget.value = ""
      }
    }
  }

  // Add a tag from suggestions
  addSuggestedTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    
    // Validate tag length
    if (!this.isValidTagLength(tag)) {
      this.showError(`Tags must be ${this.maxTagLengthValue} characters or less`)
      return
    }
    
    if (!this.hasTag(tag)) {
      this.addedTags.add(tag)
      if (this.removedTags.has(tag)) {
        this.removedTags.delete(tag)
      }
      
      this.hideError()
      this.updateTagsDisplay()
      this.updateSuggestions()
      this.inputTarget.value = ""
    }
  }

  // Remove a tag
  removeTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    
    if (this.originalTags.has(tag)) {
      this.removedTags.add(tag)
    }
    
    if (this.addedTags.has(tag)) {
      this.addedTags.delete(tag)
    }
    
    this.hideError()
    this.updateTagsDisplay()
    this.updateSuggestions()
  }

  // Filter suggestions when typing
  filterSuggestions() {
    this.updateSuggestions()
  }

  // Submit the form with batch changes
  async submitForm(event) {
    event.preventDefault()
    
    // Get the current tags (original minus removed plus added)
    const currentTags = [...this.getCurrentTags()]
    
    // Validate all tags
    if (!this.validateTags(currentTags)) {
      return
    }
    
    // Update the hidden input with the current tags
    this.hiddenInputTarget.value = JSON.stringify(currentTags)
    
    try {
      // Disable the submit button to prevent multiple submissions
      const submitButton = event.currentTarget
      submitButton.disabled = true
      submitButton.classList.add('opacity-50', 'cursor-not-allowed')
      
      // Submit the form
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method,
        body: new FormData(this.formTarget),
        headers: {
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      })
      
      if (!response.ok) {
        // Handle server error
        if (response.status === 422) {
          // Validation error
          const data = await response.json()
          this.showError(data.error || "Failed to save tags. Please check your input.")
        } else if (response.status === 401 || response.status === 403) {
          this.showError("You don't have permission to edit these tags.")
        } else {
          this.showError("Failed to save tags. Please try again.")
        }
        submitButton.disabled = false
        submitButton.classList.remove('opacity-50', 'cursor-not-allowed')
      } else {
        // Process successful response
        const contentType = response.headers.get('Content-Type')
        if (contentType && contentType.includes('text/vnd.turbo-stream.html')) {
          const responseText = await response.text()
          Turbo.renderStreamMessage(responseText)
        } else if (contentType && contentType.includes('text/html')) {
          Turbo.visit(window.location.href)
        }
      }
    } catch (error) {
      console.error("Network error:", error)
      this.showError("Network error. Please check your connection and try again.")
      
      // Re-enable the submit button
      const submitButton = event.currentTarget
      submitButton.disabled = false
      submitButton.classList.remove('opacity-50', 'cursor-not-allowed')
    }
  }

  // Reset to original tags (cancel changes)
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
    // Start with original tags
    const tags = new Set([...this.originalTags])
    
    // Remove tags that were removed
    this.removedTags.forEach(tag => tags.delete(tag))
    
    // Add new tags
    this.addedTags.forEach(tag => tags.add(tag))
    
    return tags
  }

  hasTag(tag) {
    return this.getCurrentTags().has(tag.toLowerCase())
  }

  isValidTag(tag) {
    return tag.length > 0
  }

  isValidTagLength(tag) {
    return tag.length <= this.maxTagLengthValue
  }

  validateTags(tags) {
    // Check if any tag exceeds the maximum length
    const invalidTag = tags.find(tag => tag.length > this.maxTagLengthValue)
    if (invalidTag) {
      this.showError(`Tag "${invalidTag}" exceeds the maximum length of ${this.maxTagLengthValue} characters`)
      return false
    }
    
    // Check maximum number of tags (optional, adjust as needed)
    if (tags.length > 30) {
      this.showError("You can add a maximum of 30 tags")
      return false
    }
    
    return true
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('hidden')
    } else {
      console.error(message)
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add('hidden')
    }
  }

  updateTagsDisplay() {
    if (!this.hasTagListTarget) return
    
    const currentTags = [...this.getCurrentTags()]
    
    // Clear the current tags display
    this.tagListTarget.innerHTML = ""
    
    // Add each tag with a remove button
    currentTags.forEach(tag => {
      const tagElement = document.createElement("div")
      tagElement.classList.add("inline-flex", "items-center", "bg-primary-100", "text-primary-800", "rounded-full", "px-3", "py-1", "text-sm", "font-medium", "mr-2", "mb-2")
      
      const tagText = document.createElement("span")
      tagText.textContent = tag
      
      const removeButton = document.createElement("button")
      removeButton.type = "button"
      removeButton.classList.add("ml-1", "text-primary-600", "hover:text-primary-800")
      removeButton.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      `
      removeButton.dataset.tag = tag
      removeButton.dataset.action = "click->tag-editor#removeTag"
      
      tagElement.appendChild(tagText)
      tagElement.appendChild(removeButton)
      
      this.tagListTarget.appendChild(tagElement)
    })
  }

  updateSuggestions() {
    if (!this.hasSuggestionsTarget) return
    
    const input = this.inputTarget.value.toLowerCase().trim()
    const currentTags = this.getCurrentTags()
    
    // Filter available tags
    const suggestions = this.availableTagsValue.filter(tag => {
      return !currentTags.has(tag.toLowerCase()) && 
             tag.toLowerCase().includes(input) &&
             tag.toLowerCase() !== input
    })
    
    // Clear current suggestions
    this.suggestionsTarget.innerHTML = ""
    
    if (input === "") {
      return
    }
    
    // Add each suggestion
    suggestions.slice(0, 5).forEach(tag => {
      const button = document.createElement("button")
      button.type = "button"
      button.classList.add("block", "w-full", "text-left", "px-3", "py-2", "hover:bg-surface-100")
      button.textContent = tag
      button.dataset.tag = tag
      button.dataset.action = "click->tag-editor#addSuggestedTag"
      
      this.suggestionsTarget.appendChild(button)
    })
    
    // Add current input as option if valid and not already a tag
    if (input && !currentTags.has(input) && !suggestions.some(s => s.toLowerCase() === input)) {
      // But only if it's not too long
      if (this.isValidTagLength(input)) {
        const button = document.createElement("button")
        button.type = "button"
        button.classList.add("block", "w-full", "text-left", "px-3", "py-2", "hover:bg-surface-100", "font-medium")
        button.textContent = `Add "${input}"`
        button.dataset.tag = input
        button.dataset.action = "click->tag-editor#addSuggestedTag"
        
        this.suggestionsTarget.appendChild(button)
      }
    }
  }
}