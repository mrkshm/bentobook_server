import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "deleteButton"]
  static values = {
    visitId: { type: String, default: '' },
    restaurantId: { type: String, default: '' },
    currentLocale: String,
    successMessage: String,
    errorMessage: String,
    networkErrorMessage: String,
    confirmMessageSingle: String,
    confirmMessageMultiple: String
  }
  
  connect() {
    this.selectedImageIds = new Set()
  }

  toggle(event) {
    const button = event.currentTarget
    const imageId = button.dataset.imageId
    
    button.classList.toggle("selected")
    
    if (button.classList.contains("selected")) {
      this.selectedImageIds.add(imageId)
    } else {
      this.selectedImageIds.delete(imageId)
    }

    console.log("Image toggled:", {
      imageId,
      selected: button.classList.contains("selected"),
      currentlySelected: Array.from(this.selectedImageIds)
    })
  }

  showSelected(event) {
    event.preventDefault()
  }

  async confirmAndDelete(event) {
    event.preventDefault()
    
    const count = this.selectedImageIds.size
    if (count === 0) return

    const confirmMessage = count === 1 ? 
      this.confirmMessageSingleValue : 
      this.confirmMessageMultipleValue.replace('%{count}', count)
    
    if (!confirm(confirmMessage)) return

    const button = this.deleteButtonTarget
    const originalText = button.textContent
    button.disabled = true
    button.textContent = "Deleting..."

    try {
      const response = await fetch(`/images/bulk_destroy`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          image_ids: Array.from(this.selectedImageIds)
        })
      })

      if (response.ok) {
        const successMessage = count === 1 ? 
          this.successMessageValue : 
          this.successMessageValue.replace('%{count}', count)

        // Determine redirect path based on whether we have a visit or restaurant
        const redirectPath = this.getRedirectPath()
        
        Turbo.visit(redirectPath, { 
          action: "replace",
          flash: { notice: successMessage }
        })
      } else {
        this.showError(button, originalText, this.errorMessageValue)
      }
    } catch (error) {
      this.showError(button, originalText, this.networkErrorMessageValue)
    }
  }

  getRedirectPath() {
    if (this.visitIdValue) {
      return `/visits/${this.visitIdValue}`
    }
    if (this.restaurantIdValue) {
      return `/restaurants/${this.restaurantIdValue}`
    }
    throw new Error('Neither visitId nor restaurantId was provided')
  }

  showError(button, originalText, message) {
    button.disabled = false
    button.textContent = originalText
    
    const flash = document.createElement('turbo-frame')
    flash.id = 'flash'
    flash.innerHTML = `<div class="mb-4 p-4 rounded-md bg-error-50 border border-error-200">
      <p class="text-sm text-error-700">${message}</p>
    </div>`
    document.querySelector('main').prepend(flash)
  }
}