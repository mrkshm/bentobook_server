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
      const imageContainer = event.currentTarget.closest('.image-thumbnail')
      
      const url = `/images/${imageId}`

      const headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      }

      fetch(url, {
        method: 'DELETE',
        headers: headers,
        credentials: 'same-origin'
      })
      .then(response => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.errors?.join(', ') || 'Network response was not ok')
          })
        }
        return response.json()
      })
      .then(data => {
        if (data.success) {
          if (imageContainer) {
            imageContainer.remove()
          }
        }
      })
      .catch(error => {
        console.error("Error:", error)
        if (error.message !== 'Network response was not ok') {
          alert(error.message || 'Failed to delete image')
        }
      })
    }
  }
}
