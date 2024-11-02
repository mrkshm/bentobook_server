import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["deleteButton"]
  static values = {
    imageableType: String,
    imageableId: String
  }

  connect() {
    console.log("Image Deletion controller connected")
  }

  deleteImage(event) {
    console.log("deleteImage method called")
    event.preventDefault()
    
    if (confirm("Are you sure you want to delete this image?")) {
      const imageId = event.currentTarget.dataset.imageId
      const imageableType = this.imageableTypeValue.toLowerCase()
      const imageableId = this.imageableIdValue

      const headers = {
        'Accept': 'application/json'
      }

      const csrfToken = document.querySelector('meta[name="csrf-token"]')
      if (csrfToken) {
        headers['X-CSRF-Token'] = csrfToken.content
      } else {
        console.warn('CSRF token not found')
      }

      fetch(`/${imageableType}s/${imageableId}/images/${imageId}`, {
        method: 'DELETE',
        headers: headers
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Remove from both preview and main display
          const imageContainer = event.target.closest('.image-thumbnail')
          if (imageContainer) {
            imageContainer.remove()
          }
          
          // Also remove from the main display if it exists
          const mainDisplay = document.querySelector(`[data-image-id="${imageId}"]`)?.closest('.relative.group')
          if (mainDisplay) {
            mainDisplay.remove()
          }
          
          // Refresh the form state
          const form = document.querySelector('form')
          if (form) {
            form.dataset.changed = 'false'
          }
        } else {
          alert('Failed to delete image: ' + (data.errors ? data.errors.join(', ') : 'Unknown error'))
        }
      })
      .catch(error => {
        console.error("Error during image deletion:", error)
        alert('An error occurred while deleting the image')
      })
    }
  }
}
