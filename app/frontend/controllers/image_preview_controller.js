import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview", "inputContainer"];

  connect() {
  }

  triggerFileInput(event) {
    event.preventDefault();
    this.inputTarget.click();
  }

  handleFiles() {
    const files = this.inputTarget.files;

    if (files?.length > 0) {
      this.previewTarget.innerHTML = '';
      Array.from(files).forEach(file => {
        this.createPreview(file);
      });
    } else {
      this.reset();
    }
  }

  createPreview(file) {
    if (!file.type.startsWith('image/')) {
      return;
    }

    const reader = new FileReader();
    const preview = document.createElement('div');
    preview.className = 'relative image-thumbnail';
    
    const img = document.createElement('img');
    img.className = 'rounded-lg shadow-md w-full h-48 object-cover';
    
    // Add the preview to the DOM first
    this.previewTarget.appendChild(preview);
    
    reader.onload = (e) => {
      // Set the source and append the image
      img.src = e.target.result;
      preview.appendChild(img);
      
      // Add remove button
      const removeBtn = document.createElement('button');
      removeBtn.type = 'button';
      removeBtn.className = 'absolute -top-2 -right-2 bg-white rounded-full p-1 shadow-md text-red-600 hover:text-red-800';
      removeBtn.innerHTML = '×';
      removeBtn.onclick = (e) => {
        e.preventDefault();
        preview.remove();
        if (this.previewTarget.children.length === 0) {
          this.reset();
        }
      }
      preview.appendChild(removeBtn);
      
      // Add filename display
      const fileNameDisplay = document.createElement('div');
      fileNameDisplay.className = 'text-xs text-surface-600 truncate mt-1 px-1';
      fileNameDisplay.textContent = file.name;
      preview.appendChild(fileNameDisplay);
    }

    reader.onerror = (e) => {
    }

    reader.readAsDataURL(file);
  }

  reset() {
    this.inputTarget.value = '';
    this.previewTarget.innerHTML = '';
  }
}
