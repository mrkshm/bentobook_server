import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star"]
  static values = {
    rating: Number
  }

  connect() {
    this.rating = this.ratingValue || 0
    this.updateStars()
  }

  setRating(event) {
    event.preventDefault()
    const newRating = parseInt(event.currentTarget.dataset.value)
    
    // Disable stars during submission
    this.starTargets.forEach(star => star.disabled = true)
    
    if (this.element.dataset.ratingsUrl) {
      const formData = new FormData()
      formData.append("restaurant[rating]", newRating)
      
      // Update UI immediately for better UX
      this.rating = newRating
      this.updateStars()
      
      fetch(this.element.dataset.ratingsUrl, {
        method: 'PATCH',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: formData,
        credentials: 'same-origin'
      }).then(response => {
        if (!response.ok) {
          // Reset to previous state if request failed
          this.rating = this.ratingValue
          this.updateStars()
          throw new Error('Network response was not ok')
        }
        return response.text()
      }).then(html => {
        Turbo.renderStreamMessage(html)
      }).catch(error => {
        console.error('Error updating rating:', error)
      }).finally(() => {
        // Re-enable stars
        this.starTargets.forEach(star => star.disabled = false)
      })
    } else {
      // Local update only (no server)
      this.rating = newRating
      this.updateStars()
      this.starTargets.forEach(star => star.disabled = false)
    }
  }

  hoverRating(event) {
    const hoverValue = parseInt(event.currentTarget.dataset.value)
    this.starTargets.forEach((star, index) => {
      if (index < hoverValue) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-500")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-500")
      }
    })
  }

  resetRating() {
    this.updateStars()
  }

  updateStars() {
    this.starTargets.forEach((star, index) => {
      if (index < this.rating) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-500")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-500")
      }
      star.disabled = false
    })
  }
}