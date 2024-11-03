import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    imageableType: String,
    imageableId: Number
  }

  connect() {
    console.log("Image Deletion controller connected")
  }

  deleteImage(event) {
    event.preventDefault()
    
    if (confirm("Are you sure you want to delete this image?")) {
      const imageId = event.currentTarget.dataset.imageId
      
      const url = `/images/${imageId}`

      const headers = {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      }

      fetch(url, {
        method: 'DELETE',
        headers: headers,
        credentials: 'same-origin'
      })
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      })
      .then(data => {
        if (data.success) {
          const imageContainer = event.currentTarget.closest('.image-thumbnail')
          if (imageContainer) {
            imageContainer.remove()
          }
        } else {
          throw new Error(data.message || 'Delete failed')
        }
      })
      .catch(error => {
        console.error("Error:", error)
        alert('Failed to delete image')
      })
    }
  }
}
