import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "starsContainer"]
  static values = {
    rating: Number,
    url: String
  }

  connect() {
    console.log("Ratings controller connected", this.element)
    this.rating = this.ratingValue || 0
    this.updateStars()
  }

  openModal(event) {
    console.log("Opening modal")
    event.preventDefault()
    const modalId = `${this.element.id}_modal`
    console.log("Looking for modal with ID:", modalId)
    const modal = document.getElementById(modalId)
    console.log("Found modal:", modal)
    
    if (modal) {
      // Use the global Stimulus instance
      const modalController = window.Stimulus.getControllerForElementAndIdentifier(modal, 'modal')
      console.log("Modal controller:", modalController)
      if (modalController) {
        modalController.open()
      } else {
        console.error("Modal controller not found")
      }
    }
  }

  setRating(event) {
    event.preventDefault()
    const newRating = parseInt(event.currentTarget.dataset.value)
    
    // Disable stars during submission
    this.starTargets.forEach(star => star.disabled = true)
    
    if (this.urlValue) {
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
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      }).then(data => {
        // Close the modal after successful update
        const modalId = `${this.element.id}_modal`
        const modal = document.getElementById(modalId)
        if (modal) {
          const modalController = window.Stimulus.getControllerForElementAndIdentifier(modal, 'modal')
          if (modalController) {
            modalController.close()
          }
        }
      }).catch(error => {
        console.error('Error:', error)
      }).finally(() => {
        // Re-enable stars
        this.starTargets.forEach(star => star.disabled = false)
      })
    }
  }

  updateStars() {
    const stars = this.element.querySelectorAll('[data-ratings-target="star"]')
    stars.forEach((star, index) => {
      const starValue = index + 1
      if (starValue <= this.rating) {
        star.classList.remove('text-gray-500')
        star.classList.add('text-yellow-400')
      } else {
        star.classList.remove('text-yellow-400')
        star.classList.add('text-gray-500')
      }
    })
  }
}