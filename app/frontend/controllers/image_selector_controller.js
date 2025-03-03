import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "deleteButton"]
  static values = {
    restaurantId: String,
    currentLocale: String
  }
  
  connect() {
    console.log("🚨 CONNECTING IMAGE SELECTOR")
    alert("Image selector connected!")
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
    console.log("Delete button clicked!")
    console.log("Currently selected:", Array.from(this.selectedImageIds))
  }

  async confirmAndDelete(event) {
    event.preventDefault()
    
    if (!confirm("Delete selected images?")) {
      return
    }

    const button = this.deleteButtonTarget
    const originalText = button.textContent
    button.disabled = true
    button.textContent = "Deleting..."

    try {
      const response = await fetch('/images/bulk_destroy', {
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

      const data = await response.json()

      if (response.ok) {
        const currentPath = window.location.pathname
        const restaurantPath = currentPath.replace('/images/edit', '')
        
        Turbo.visit(restaurantPath, { 
          action: "replace",
          flash: { notice: `Successfully deleted ${this.selectedImageIds.size} photos` }
        })
      } else {
        // Reset button state
        button.disabled = false
        button.textContent = originalText
        
        // Show error in flash message
        const flash = document.createElement('turbo-frame')
        flash.id = 'flash'
        flash.innerHTML = `
          <div class="mb-4">
            <div class="p-4 rounded-md bg-error-50 border border-error-200">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg class="h-5 w-5 text-error-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm text-error-700">${data.error || 'Failed to delete photos'}</p>
                </div>
              </div>
            </div>
          </div>
        `
        document.querySelector('main').prepend(flash)
      }
    } catch (error) {
      // Reset button state
      button.disabled = false
      button.textContent = originalText
      
      // Show network error flash
      const flash = document.createElement('turbo-frame')
      flash.id = 'flash'
      flash.innerHTML = `
        <div class="mb-4">
          <div class="p-4 rounded-md bg-error-50 border border-error-200">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-error-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                </svg>
              </div>
              <div class="ml-3">
                <p class="text-sm text-error-700">Network error. Please try again.</p>
              </div>
            </div>
          </div>
        </div>
      `
      document.querySelector('main').prepend(flash)
    }
  }
}