import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]

  connect() {
    console.log("Modal controller connected")
    this.element.classList.add("hidden")
  }

  open() {
    this.element.classList.remove("hidden")
    
    // Start transitions after a small delay
    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.overlayTarget.classList.add("opacity-100")
      this.contentTarget.classList.remove("opacity-0", "scale-95")
      this.contentTarget.classList.add("opacity-100", "scale-100")
    })
    
    document.body.style.overflow = "hidden"
    this.trapFocus()
  }

  close() {
    
    // Start the closing transition
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.contentTarget.classList.remove("opacity-100", "scale-100")
    this.contentTarget.classList.add("opacity-0", "scale-95")
    
    // Wait for the transition to complete before hiding
    setTimeout(() => {
      this.element.classList.add("hidden")
      document.body.style.overflow = ""
      this.releaseFocus()
    }, 300)
  }

  trapFocus() {
    this.previouslyFocused = document.activeElement
    this.element.focus()
  }

  releaseFocus() {
    if (this.previouslyFocused) {
      this.previouslyFocused.focus()
    }
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
