import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dollar"]
  static values = {
    level: Number,
    url: String
  }

  connect() {
    this.level = this.levelValue || 0
    this.updateDollars()
  }

  // Add logging like in ratings controller
  openModal(event) {
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

  // Match setRating pattern
  setLevel(event) {
    event.preventDefault()
    const newLevel = parseInt(event.currentTarget.dataset.value)
    
    if (this.urlValue) {
      const formData = new FormData()
      formData.append("restaurant[price_level]", newLevel)
      
      fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        },
        body: formData
      }).then(response => {
        if (!response.ok) throw new Error(`Network response was not ok: ${response.status}`)
        return response.text()
      }).then(html => {
        const modal = this.element.closest('[data-controller="modal"]')
        if (modal) {
          const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
          if (modalController) modalController.close()
        }
        Turbo.renderStreamMessage(html)
      }).catch(error => {
        console.error("Error updating price level:", error)
        this.level = this.levelValue
        this.updateDollars()
      })
    }
  }

  updateDollars() {
    this.dollarTargets.forEach(dollar => {
      const value = parseInt(dollar.dataset.value)
      const dollarIcon = dollar.querySelector('svg')
      if (dollarIcon) {
        if (value <= this.level) {
          dollarIcon.classList.remove('text-gray-400')
          dollarIcon.classList.add('text-green-600')
        } else {
          dollarIcon.classList.remove('text-green-600')
          dollarIcon.classList.add('text-gray-400')
        }
      }
    })
  }
}