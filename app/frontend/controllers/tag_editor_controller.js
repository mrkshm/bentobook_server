import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tagList", "suggestions", "hiddenInput", "originalTags", "form"]
  static values = { 
    availableTags: Array,
    currentTags: Array
  }

  connect() {
    // Initialize tags from the hidden input if available
    this.originalTags = new Set(this.currentTagsValue || [])
    this.addedTags = new Set()
    this.removedTags = new Set()
    
    // Update the UI to reflect current state
    this.updateTagsDisplay()
    this.updateSuggestions()
  }

  // Add a new tag when Enter is pressed
  addTag(event) {
    if (event.key === "Enter" && this.inputTarget.value.trim() !== "") {
      event.preventDefault()
      
      const tag = this.inputTarget.value.trim().toLowerCase()
      
      if (this.isValidTag(tag) && !this.hasTag(tag)) {
        this.addedTags.add(tag)
        if (this.removedTags.has(tag)) {
          this.removedTags.delete(tag)
        }
        
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
    
    if (!this.hasTag(tag)) {
      this.addedTags.add(tag)
      if (this.removedTags.has(tag)) {
        this.removedTags.delete(tag)
      }
      
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
    
    this.updateTagsDisplay()
    this.updateSuggestions()
  }

  // Filter suggestions when typing
  filterSuggestions() {
    this.updateSuggestions()
  }

  // Submit the form with batch changes
  submitForm(event) {
    event.preventDefault()
    
    // Get the current tags (original minus removed plus added)
    const currentTags = [...this.getCurrentTags()]
    
    // Update the hidden input with the current tags
    this.hiddenInputTarget.value = JSON.stringify(currentTags)
    
    // Submit the form
    this.formTarget.requestSubmit()
  }

  // Reset to original tags (cancel changes)
  cancelChanges(event) {
    if (event) event.preventDefault()
    
    this.addedTags.clear()
    this.removedTags.clear()
    
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