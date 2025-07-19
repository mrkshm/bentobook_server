import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview", "uploadButton", "overlay", "progressBar", "progressText"]
  static values = { directUploadUrl: String }

  connect() {
    console.log("ImageUploadController: Connected.")
    if (this.hasInputTarget) console.log("ImageUploadController: inputTarget found.")
    if (this.hasPreviewTarget) console.log("ImageUploadController: previewTarget found.")
    if (this.hasUploadButtonTarget) console.log("ImageUploadController: uploadButtonTarget found.")
    if (this.hasOverlayTarget) console.log("ImageUploadController: overlayTarget found.")
    if (this.hasProgressBarTarget) console.log("ImageUploadController: progressBarTarget found.")
    if (this.hasProgressTextTarget) console.log("ImageUploadController: progressTextTarget found.")
    console.log("ImageUploadController: Event listeners will be managed manually.")
  }

  disconnect() {
    console.log("ImageUploadController: Disconnecting.")
    console.log("ImageUploadController: Event listeners were managed manually.")
  }

  preview(event) {
    console.log("ImageUploadController: preview action triggered.")
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
    event.preventDefault() // Prevent default form submission
    console.log("ImageUploadController: submitForm action triggered.")

    this.overlayTarget.classList.remove("hidden")
    this.uploadButtonTarget.disabled = true
    this.uploadButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    this.updateProgressBar(0)

    const files = Array.from(this.inputTarget.files)
    const uploads = files.map(file => this.createDirectUpload(file))

    try {
      await Promise.all(uploads.map(upload => this.performUpload(upload)))
      console.log("ImageUploadController: All direct uploads complete. Submitting form.")

      // Clear the file input to prevent raw file data from being sent again
      const dataTransfer = new DataTransfer()
      this.inputTarget.files = dataTransfer.files

      this.element.submit() // Submit the form after all direct uploads are done
    } catch (error) {
      console.error("ImageUploadController: Error during direct uploads:", error)
      this.handleError({ detail: { error: error.message || "Unknown upload error" } })
    }
  }

  createDirectUpload(file) {
    // Use the directUploadUrlValue from Stimulus values
    const url = this.directUploadUrlValue
    const upload = new DirectUpload(file, url, this) // 'this' is the delegate
    return upload
  }

  performUpload(upload) {
    return new Promise((resolve, reject) => {
      upload.create((error, blob) => {
        if (error) {
          reject(error)
        } else {
          // Append a hidden input with the signed_id to the form
          const hiddenField = document.createElement('input')
          hiddenField.setAttribute('type', 'hidden')
          hiddenField.setAttribute('name', this.inputTarget.name.replace('[]', '') + '[]') // Adjust name for multiple files
          hiddenField.setAttribute('value', blob.signed_id)
          this.element.appendChild(hiddenField)
          resolve(blob)
        }
      })
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    const progress = (event.loaded / event.total) * 100
    console.log("ImageUploadController: directUploadDidProgress:", progress)
    this.updateProgressBar(progress)
  }

  handleError(event) {
    console.error("ImageUploadController: Error:", event.detail)
    this.overlayTarget.classList.add("hidden")
    this.uploadButtonTarget.disabled = false
    this.uploadButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    alert("Upload failed: " + event.detail.error) // Simple error display
  }

  endUpload(event) {
    // This event is not directly used in this manual flow, as we control submission after all uploads
    console.log("ImageUploadController: endUpload (not directly used in manual flow)")
  }

  updateProgressBar(value) {
    this.progressBarTarget.style.setProperty("--value", value)
    this.progressTextTarget.textContent = `${Math.round(value)}%`
  }
}