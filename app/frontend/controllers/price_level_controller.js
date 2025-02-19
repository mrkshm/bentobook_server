import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dollar"]
  static values = {
    level: Number,
    url: String
  }

  connect() {
    console.log("Price level controller connected", {
      element: this.element,
      dollars: this.dollarTargets,
      url: this.urlValue,
      level: this.levelValue
    })
    this.level = this.levelValue || 0
    this.updateDollars()
  }

  // Add logging like in ratings controller
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

  // Match setRating pattern
  setLevel(event) {
    console.log("Setting price level...")
    event.preventDefault()
    const newLevel = parseInt(event.currentTarget.dataset.value)
    console.log("New level:", newLevel)
    
    // Disable dollars during submission
    this.dollarTargets.forEach(dollar => dollar.disabled = true)
    
    if (this.urlValue) {
      const formData = new FormData()
      formData.append("restaurant[price_level]", newLevel)
      
      // Update UI immediately for better UX
      this.level = newLevel
      this.updateDollars()
      
      fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html, application/json'
        },
        body: formData
      }).then(response => {
        if (!response.ok) throw new Error(`Network response was not ok: ${response.status}`)
        
        const contentType = response.headers.get("Content-Type")
        if (contentType && contentType.includes("text/vnd.turbo-stream.html")) {
          return response.text().then(html => {
            const modal = this.element.closest('[data-controller="modal"]')
            if (modal) {
              const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
              if (modalController) modalController.close()
            }
            Turbo.renderStreamMessage(html)
          })
        }
        return response.json()
      }).then(data => {
        if (data) {
          this.level = data.price_level
          this.updateDollars()
          const modal = this.element.closest('[data-controller="modal"]')
          if (modal) {
            const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
            if (modalController) modalController.close()
          }
        }
      }).catch(error => {
        console.error('Error updating price level:', error)
        this.level = this.levelValue
        this.updateDollars()
      }).finally(() => {
        this.dollarTargets.forEach(dollar => dollar.disabled = false)
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