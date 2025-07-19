# Image Upload Progress Indicator and Overlay Implementation Plan

## Goal
To provide visual feedback to the user during image direct uploads to S3, including a progress indicator and a semi-transparent screen overlay to prevent further interaction.

## Tools
*   **Active Storage:** For direct uploads.
*   **Stimulus.js:** To manage client-side UI state and respond to Active Storage events.
*   **DaisyUI:** For the `radial-progress` component.

## Implementation Steps

### 1. Create the Progress Overlay Partial (`app/views/shared/_upload_progress_overlay.html.erb`)

This partial will contain the full-screen overlay and the DaisyUI radial progress indicator. It will be initially hidden.

```erb
<div class="fixed inset-0 bg-surface-900 bg-opacity-50 flex items-center justify-center z-50 hidden" data-image-upload-target="overlay">
  <div class="radial-progress text-primary-500" style="--value:0;" role="progressbar" aria-valuenow="0" data-image-upload-target="progressBar">
    <span data-image-upload-target="progressText">0%</span>
  </div>
</div>
```

### 2. Integrate the Partial into the Upload Form (`app/views/visits/images/new.html.erb`)

Include the new partial within the `form_with` block. The Stimulus controller will manage its visibility.

```erb
<%= form_with url: visit_images_path(visit_id: @visit.id, locale: current_locale),
    method: :post,
    multipart: true,
    data: {
      controller: "image-upload",
      turbo_frame: "_top",
      turbo_action: "replace"
    } do |form| %>

  <%# ... existing form content ... %>

  <%= render "shared/upload_progress_overlay" %>

  <div class="flex justify-end mt-6">
    <button type="submit"
            data-image-upload-target="uploadButton"
            disabled
            class="ml-4 px-4 py-2 bg-primary-600 text-white rounded-md opacity-50 cursor-not-allowed transition-colors">
      <%= t("images.upload.upload") %>
    </button>
  </div>
<% end %>
```

### 3. Enhance the `image-upload` Stimulus Controller (`app/frontend/controllers/image_upload_controller.js`)

This is the core logic. The controller will listen for Active Storage's direct upload events and update the UI accordingly.

*   **Add new targets:** `overlay`, `progressBar`, `progressText`.
*   **Listen for Active Storage events:**
    *   `direct-upload:initialize`: Show the overlay, reset progress.
    *   `direct-upload:start`: Enable the submit button (if not already), ensure overlay is visible.
    *   `direct-upload:progress`: Update the `radial-progress` `--value` CSS variable and the displayed percentage text.
    *   `direct-upload:error`: Hide the overlay, enable the submit button, show an error message (optional, but recommended).
    *   `direct-upload:end`: Hide the overlay, enable the submit button.

```javascript
// app/frontend/controllers/image_upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "uploadButton", "overlay", "progressBar", "progressText"]

  connect() {
    console.log("ImageUploadController connected")
    this.inputTarget.addEventListener("direct-upload:initialize", this.initializeUpload.bind(this))
    this.inputTarget.addEventListener("direct-upload:start", this.startUpload.bind(this))
    this.inputTarget.addEventListener("direct-upload:progress", this.updateProgress.bind(this))
    this.inputTarget.addEventListener("direct-upload:error", this.handleError.bind(this))
    this.inputTarget.addEventListener("direct-upload:end", this.endUpload.bind(this))
  }

  disconnect() {
    this.inputTarget.removeEventListener("direct-upload:initialize", this.initializeUpload.bind(this))
    this.inputTarget.removeEventListener("direct-upload:start", this.startUpload.bind(this))
    this.inputTarget.removeEventListener("direct-upload:progress", this.updateProgress.bind(this))
    this.inputTarget.removeEventListener("direct-upload:error", this.handleError.bind(this))
    this.inputTarget.removeEventListener("direct-upload:end", this.endUpload.bind(this))
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

  initializeUpload(event) {
    console.log("Upload initialized")
    this.overlayTarget.classList.remove("hidden")
    this.updateProgressBar(0)
  }

  startUpload(event) {
    console.log("Upload started")
    // Ensure overlay is visible and button is disabled
    this.overlayTarget.classList.remove("hidden")
    this.uploadButtonTarget.disabled = true
    this.uploadButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
  }

  updateProgress(event) {
    const { progress } = event.detail
    console.log("Upload progress:", progress)
    this.updateProgressBar(progress)
  }

  handleError(event) {
    console.error("Upload error:", event.detail)
    this.overlayTarget.classList.add("hidden")
    this.uploadButtonTarget.disabled = false
    this.uploadButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    alert("Upload failed: " + event.detail.error) // Simple error display
  }

  endUpload(event) {
    console.log("Upload ended")
    this.overlayTarget.classList.add("hidden")
    this.uploadButtonTarget.disabled = false
    this.uploadButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    // The form submission will handle navigation/replacement
  }

  updateProgressBar(value) {
    this.progressBarTarget.style.setProperty("--value", value)
    this.progressTextTarget.textContent = `${Math.round(value)}%`
  }
}
```

### 4. CSS Considerations

*   The `fixed inset-0` and `z-50` classes on the overlay `div` ensure it covers the entire viewport and stays on top.
*   `bg-opacity-50` provides the grayed-out effect.
*   DaisyUI's `radial-progress` handles its own styling based on the `--value` CSS variable.

This plan provides a comprehensive approach to implementing the desired progress indicator and overlay.
