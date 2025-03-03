import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "deleteButton"]
  static values = {
    restaurantId: String,
    currentLocale: String  // Add this
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
    console.log("Current URL:", window.location.pathname)
    
    if (!confirm("Delete selected images?")) {
      return
    }

    try {
      const response = await fetch('/images/bulk_destroy', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',  // Add this line
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          image_ids: Array.from(this.selectedImageIds)
        })
      })

      if (response.ok) {
        // Remove /images/edit from current path to get back to restaurant
        const currentPath = window.location.pathname
        const restaurantPath = currentPath.replace('/images/edit', '')
        console.log("Navigating to:", restaurantPath)
        
        Turbo.visit(restaurantPath, { action: "replace" })
      }
    } catch (error) {
      console.error("Failed to delete images:", error)
    }
  }
}