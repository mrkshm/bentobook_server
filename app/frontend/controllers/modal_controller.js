import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]

  connect() {
    // Initialize modal in hidden state
    this.element.classList.add("hidden")
  }

  open() {
    // Show modal container
    this.element.classList.remove("hidden")
    
    // Start transitions after a small delay
    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.overlayTarget.classList.add("opacity-100")
      this.contentTarget.classList.remove("opacity-0", "scale-95")
      this.contentTarget.classList.add("opacity-100", "scale-100")
    })
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
  }

  close() {
    // Start the closing transition
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.contentTarget.classList.remove("opacity-100", "scale-100")
    this.contentTarget.classList.add("opacity-0", "scale-95")
    
    // Hide modal after transition
    setTimeout(() => {
      this.element.classList.add("hidden")
      document.body.style.overflow = ""
    }, 300)
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      event.stopPropagation() // Prevent other controllers from handling Escape
      this.close()
    }
  }

  handleClick(event) {
    // If clicked element or its parent has the ignore attribute, don't close
    const clickedElement = event.target
    const shouldIgnore = clickedElement.closest('[data-modal-ignore-click]')
    
    if (!shouldIgnore) {
      event.preventDefault()
      this.close()
    }
  }
}
