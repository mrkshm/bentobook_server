import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview", "uploadButton", "overlay", "progressBar", "progressText"]
  static values = { directUploadUrl: String }

  connect() {
    this.uploads = new Map()
    this.isUploading = false
  }

  preview(event) {
    this.previewTarget.innerHTML = "" // Clear existing previews
    if (event.target.files.length > 0) {
      this.uploadButtonTarget.disabled = false
      this.uploadButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      Array.from(event.target.files).forEach(file => {
        const reader = new FileReader()
        reader.onload = (e) => {
          const img = document.createElement("img")
          img.src = e.target.result
          img.classList.add("w-full", "h-32", "object-cover", "rounded-lg")
          const div = document.createElement("div")
          div.classList.add("relative")
          div.appendChild(img)
          this.previewTarget.appendChild(div)
        }
        reader.readAsDataURL(file)
      })
    } else {
      this.uploadButtonTarget.disabled = true
      this.uploadButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  async submitForm(event) {
    event.preventDefault()
    
    // Prevent multiple simultaneous uploads
    if (this.isUploading) {
      console.log('Upload already in progress, ignoring')
      return
    }
    
    this.isUploading = true
    this.overlayTarget.classList.remove("hidden")
    this.uploadButtonTarget.disabled = true
    this.updateProgressBar(0)

    const files = Array.from(this.inputTarget.files)
    if (files.length === 0) {
      this.isUploading = false
      return
    }

    try {
      console.log('Starting upload process for', files.length, 'files')
      const blobs = await Promise.all(files.map(file => this.uploadFile(file)))
      console.log('All uploads complete, submitting form')
      blobs.forEach(blob => this.appendBlob(blob))
      
      // Clear the file input to prevent sending file data
      this.inputTarget.value = ''
      
      // Reset the uploading flag before submitting
      this.isUploading = false
      
      // Use the form's built-in FormData (now that file input is cleared)
      const formData = new FormData(this.element)
      
      console.log('Form data:', Array.from(formData.entries()))
      
      try {
        const response = await fetch(this.element.action, {
          method: 'POST',
          body: formData,
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        
        console.log('Form submission response:', response.status, response.statusText)
        
        if (response.ok) {
          // Handle successful response
          if (response.redirected) {
            window.location.href = response.url
          } else {
            const text = await response.text()
            console.log('Response text:', text)
          }
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (fetchError) {
        console.error('Form submission error:', fetchError)
        throw fetchError
      }
    } catch (error) {
      this.isUploading = false
      this.handleError(error.message || "An unknown error occurred")
    }
  }

  uploadFile(file) {
    return new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, this.directUploadUrlValue, this)
      
      // Add a timeout to prevent infinite waiting
      const timeout = setTimeout(() => {
        reject(new Error(`Upload timeout for ${file.name}`))
      }, 60000) // 60 second timeout
      
      upload.create((error, blob) => {
        clearTimeout(timeout)
        if (error) {
          reject(error)
        } else {
          resolve(blob)
        }
      })
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    // Add progress tracking to the XHR request
    request.upload.addEventListener("progress", event => {
      if (event.lengthComputable) {
        const progress = (event.loaded / event.total) * 100
        this.updateProgressBar(progress)
      }
    })
  }

  appendBlob(blob) {
    const hiddenField = document.createElement('input')
    hiddenField.setAttribute('type', 'hidden')
    hiddenField.setAttribute('name', 'images[]')
    hiddenField.setAttribute('value', blob.signed_id)
    this.element.appendChild(hiddenField)
  }

  handleError(message) {
    this.overlayTarget.classList.add("hidden")
    this.uploadButtonTarget.disabled = false
    alert(`Upload failed: ${message}`)
  }

  updateProgressBar(value) {
    this.progressBarTarget.style.setProperty("--value", value)
    this.progressTextTarget.textContent = `${Math.round(value)}%`
  }
}