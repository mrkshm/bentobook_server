import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star"]
  static values = {
    rating: Number,
    url: String
  }

  connect() {
    console.log("Ratings controller connected", {
      element: this.element,
      stars: this.starTargets,
      url: this.urlValue,
      rating: this.ratingValue
    })
    this.rating = this.ratingValue || 0
    this.updateStars()
  }

  openModal(event) {
    console.log("Opening modal...")
    event.preventDefault()
    const modalId = `${this.element.id}_modal`
    console.log("Modal ID:", modalId)
    const modal = document.getElementById(modalId)
    console.log("Found modal:", modal)
    
    if (modal) {
      const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
      console.log("Modal controller:", modalController)
      if (modalController) {
        modalController.open()
      }
    }
  }

  setRating(event) {
    console.log("Setting rating...")
    event.preventDefault()
    const newRating = parseInt(event.currentTarget.dataset.value)
    console.log("New rating:", newRating)
    
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
          'Accept': 'application/json'
        },
        body: formData
      }).then(response => {
        console.log("Server response:", response)
        if (!response.ok) throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`)
        return response.json()
      }).then(data => {
        console.log("Rating updated successfully:", data)
        // Find and close the modal
        const modalId = `${this.element.closest('[data-controller="ratings"]').id}_modal`
        const modal = document.getElementById(modalId)
        if (modal) {
          const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
          if (modalController) {
            modalController.close()
          }
        }

        // Update all instances of this rating component
        document.querySelectorAll(`[data-controller="ratings"][data-ratings-url-value="${this.urlValue}"]`).forEach(el => {
          const controller = this.application.getControllerForElementAndIdentifier(el, 'ratings')
          if (controller && controller !== this) {
            controller.rating = newRating
            controller.updateStars()
          }
        })
      }).catch(error => {
        console.error('Error updating rating:', error)
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
    console.log("Updating stars UI:", {
      rating: this.rating,
      stars: this.starTargets
    })
    
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