import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["star"]
  static values = {
    rating: Number,
    url: String
  }

  connect() {
    this.rating = this.ratingValue || 0
    this.updateStars()
  }

  openModal(event) {
    console.log("Opening modal...")
    event.preventDefault()
    const modalId = `${this.element.id}_modal`
    const modal = document.getElementById(modalId)
    
    if (modal) {
      const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
      if (modalController) {
        modalController.open()
      }
    }
  }

  setRating(event) {
    console.log("Setting rating...")
    event.preventDefault()
    const newRating = parseInt(event.currentTarget.dataset.value)
    
    // Disable stars during submission
    this.starTargets.forEach(star => star.disabled = true)
    
    if (this.urlValue) {
      console.log("Sending rating to server:", {
        url: this.urlValue,
        rating: newRating
      })
      
      const formData = new FormData()
      formData.append("restaurant[rating]", newRating)
      
      // Update UI immediately for better UX
      this.rating = newRating
      this.updateStars()
      
      fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html, application/json'
        },
        body: formData
      }).then(response => {
        console.log("Server response:", response)
        if (!response.ok) throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`)
        
        // Handle both Turbo Stream and JSON responses
        const contentType = response.headers.get("Content-Type")
        if (contentType && contentType.includes("text/vnd.turbo-stream.html")) {
          return response.text().then(html => {
            // Close modal before Turbo Stream updates the DOM
            const modal = this.element.closest('[data-controller="modal"]')
            if (modal) {
              const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
              if (modalController) modalController.close()
            }
            
            // Clear Turbo cache to ensure fresh data on back navigation
            Turbo.cache.clear()
            
            Turbo.renderStreamMessage(html)
          })
        }
        return response.json()
      }).then(data => {
        if (data) { // Only for JSON responses
          console.log("Rating updated successfully:", data)
          this.rating = data.rating
          this.updateStars()
          
          // Clear Turbo cache to ensure fresh data on back navigation
          Turbo.cache.clear()
          
          // Close modal after successful update
          const modal = this.element.closest('[data-controller="modal"]')
          if (modal) {
            const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
            if (modalController) modalController.close()
          }
        }
      }).catch(error => {
        // Revert the UI on error
        this.rating = this.ratingValue
        this.updateStars()
      }).finally(() => {
        // Re-enable stars
        this.starTargets.forEach(star => star.disabled = false)
      })
    } else {
      console.warn("No URL provided for rating update")
    }
  }

  updateStars() {
    
    this.starTargets.forEach(star => {
      const value = parseInt(star.dataset.value)
      const starSvg = star.querySelector('svg')
      if (starSvg) {
        if (value <= this.rating) {
          starSvg.classList.remove('text-gray-500')
          starSvg.classList.add('text-yellow-400')
        } else {
          starSvg.classList.remove('text-yellow-400')
          starSvg.classList.add('text-gray-500')
        }
      }
    })
  }
}