import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.rating = parseInt(this.inputTarget.value) || 0
    this.updateStars()
  }

  setRating(event) {
    this.rating = parseInt(event.currentTarget.dataset.value)
    this.inputTarget.value = this.rating
    this.updateStars()
  }

  hoverRating(event) {
    const hoverValue = parseInt(event.currentTarget.dataset.value)
    this.starTargets.forEach((star, index) => {
      if (index < hoverValue) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-300")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
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
        star.classList.remove("text-gray-300")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }
}