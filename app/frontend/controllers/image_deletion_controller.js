import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["deleteButton"]

  connect() {
    console.log("Image Deletion controller connected")
  }

  deleteImage(event) {
    console.log("deleteImage method called")
    event.preventDefault()
    if (confirm("Are you sure you want to delete this image?")) {
      const imageId = event.currentTarget.dataset.imageId
      const visitId = event.currentTarget.dataset.visitId

      const headers = {
        'Accept': 'application/json'
      }

      const csrfToken = document.querySelector('meta[name="csrf-token"]')
      if (csrfToken) {
        headers['X-CSRF-Token'] = csrfToken.content
      } else {
        console.warn('CSRF token not found')
      }

      fetch(`/visits/${visitId}/images/${imageId}`, {
        method: 'DELETE',
        headers: headers
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          event.target.closest('.image-thumbnail').remove()
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