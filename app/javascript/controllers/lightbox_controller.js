import { Controller } from "@hotwired/stimulus"

/**
 * Lightbox Controller
 * 
 * A simple lightbox controller for displaying images in a modal overlay.
 * Based on the @stimulus-components/lightbox package but implemented locally
 * to avoid CORS issues.
 */
export default class extends Controller {
  static targets = ["trigger"]

  connect() {
    console.log("LightboxController connected")
    this.modal = null
    this.currentImage = null
  }

  disconnect() {
    this.closeModal()
  }

  open(event) {
    event.preventDefault()
    
    const trigger = event.currentTarget
    const imageUrl = trigger.getAttribute("href")
    
    if (!imageUrl) return
    
    this.createModal(imageUrl)
  }

  createModal(imageUrl) {
    // Create modal if it doesn't exist
    if (!this.modal) {
      this.modal = document.createElement("div")
      this.modal.classList.add("fixed", "inset-0", "z-50", "flex", "items-center", "justify-center", "bg-black", "bg-opacity-90")
      this.modal.addEventListener("click", this.handleBackdropClick.bind(this))
      
      // Add keyboard event listener
      document.addEventListener("keydown", this.handleKeyDown.bind(this))
    }
    
    // Create or update image
    if (!this.currentImage) {
      this.currentImage = document.createElement("img")
      this.currentImage.classList.add("max-h-[90vh]", "max-w-[90vw]", "object-contain")
      this.modal.appendChild(this.currentImage)
    }
    
    // Set image source
    this.currentImage.src = imageUrl
    
    // Add modal to DOM
    document.body.appendChild(this.modal)
    document.body.classList.add("overflow-hidden")
  }

  closeModal() {
    if (this.modal && this.modal.parentNode) {
      this.modal.parentNode.removeChild(this.modal)
      document.body.classList.remove("overflow-hidden")
      document.removeEventListener("keydown", this.handleKeyDown.bind(this))
    }
  }

  handleBackdropClick(event) {
    if (event.target === this.modal) {
      this.closeModal()
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.closeModal()
    }
  }
}
