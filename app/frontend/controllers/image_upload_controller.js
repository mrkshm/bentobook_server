import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "uploadButton"]
  
  connect() {
    this.selectedFiles = []
  }
  
  preview(event) {
    const files = event.target.files
    if (!files || files.length === 0) return
    
    // Clear previous previews if any
    this.previewTarget.innerHTML = ''
    this.selectedFiles = Array.from(files)
    
    // Enable upload button if files are selected
    this.uploadButtonTarget.disabled = false
    this.uploadButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    this.uploadButtonTarget.classList.add("hover:bg-primary-700")
    
    // Generate previews for each file
    this.selectedFiles.forEach((file, index) => {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        const previewContainer = document.createElement('div')
        previewContainer.className = 'relative'
        previewContainer.innerHTML = `
          <img src="${e.target.result}" class="w-full h-40 object-cover rounded-lg shadow-sm" />
          <button type="button" data-action="click->image-upload#removeImage" data-index="${index}" class="absolute top-2 right-2 bg-surface-900 bg-opacity-60 text-white rounded-full p-1 hover:bg-surface-800">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        `
        
        this.previewTarget.appendChild(previewContainer)
      }
      
      reader.readAsDataURL(file)
    })
  }
  
  removeImage(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    
    // Remove the file from the selection
    this.selectedFiles = this.selectedFiles.filter((_, i) => i !== index)
    
    // Update the file input
    const dataTransfer = new DataTransfer()
    this.selectedFiles.forEach(file => dataTransfer.items.add(file))
    this.element.querySelector('input[type="file"]').files = dataTransfer.files
    
    // Regenerate all previews with updated indices
    this.previewTarget.innerHTML = ''
    this.selectedFiles.forEach((file, idx) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        // Create preview with updated index
        const previewContainer = document.createElement('div')
        previewContainer.className = 'relative'
        previewContainer.innerHTML = `
          <img src="${e.target.result}" class="w-full h-40 object-cover rounded-lg shadow-sm" />
          <button type="button" data-action="click->image-upload#removeImage" data-index="${idx}" class="absolute top-2 right-2 bg-surface-900 bg-opacity-60 text-white rounded-full p-1 hover:bg-surface-800">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        `
        this.previewTarget.appendChild(previewContainer)
      }
      reader.readAsDataURL(file)
    })
    
    // Disable upload button if no files are selected
    if (this.selectedFiles.length === 0) {
      this.uploadButtonTarget.disabled = true
      this.uploadButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.uploadButtonTarget.classList.remove("hover:bg-primary-700")
    }
  }
}