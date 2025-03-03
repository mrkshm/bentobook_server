import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "deleteButton"]
  
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
}