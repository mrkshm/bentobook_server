import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview", "inputContainer"];

  connect() {
    console.log("Image preview controller connected");
  }

  triggerFileInput(event) {
    console.log("triggerFileInput called");
    event.preventDefault();
    this.inputTarget.click();
  }

  handleFiles() {
    console.log("handleFiles called");
    const files = this.inputTarget.files;
    
    if (files?.length > 0) {
      this.previewTarget.innerHTML = '';
      Array.from(files).forEach(file => this.createPreview(file));
    } else {
      this.reset();
    }
  }

  createPreview(file) {
    if (!file.type.startsWith('image/')) return;

    const reader = new FileReader();
    const preview = document.createElement('div');
    preview.className = 'relative image-thumbnail';
    
    const img = document.createElement('img');
    img.className = 'rounded-lg shadow-md w-full h-48 object-cover';
    
    reader.onload = (e) => {
      img.src = e.target.result;
      preview.appendChild(img);
      
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
    }

    reader.readAsDataURL(file);
    this.previewTarget.appendChild(preview);
  }

  reset() {
    this.inputTarget.value = '';
    this.previewTarget.innerHTML = '';
  }
}
