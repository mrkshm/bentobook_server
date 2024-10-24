import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview", "noFileMessage", "inputContainer"];

  connect() {
    console.log("Image preview controller connected");
  }

  triggerFileInput(event) {
    event.preventDefault();
    this.inputTarget.click();
  }

  handleFiles() {
    console.log("Handling files");
    const files = this.inputTarget.files;
    console.log("Files selected:", files?.length);
    
    if (files?.length > 0) {
      if (this.hasNoFileMessageTarget) {
        this.noFileMessageTarget.classList.add('hidden');
      }
      this.previewTarget.innerHTML = '';
      Array.from(files).forEach(file => this.createPreview(file));
    } else {
      this.reset();
    }
  }

  createPreview(file) {
    console.log("Creating preview for file:", file.name);
    if (!file.type.startsWith('image/')) {
      console.log("Not an image file:", file.type);
      return;
    }

    const reader = new FileReader();
    const preview = document.createElement('div');
    preview.className = 'relative image-thumbnail';
    
    const img = document.createElement('img');
    img.className = 'rounded-lg shadow-md w-full h-48 object-cover';
    
    reader.onload = (e) => {
      console.log("File read complete");
      img.src = e.target.result;
      preview.appendChild(img);
      
      const removeBtn = document.createElement('button');
      removeBtn.type = 'button';
      removeBtn.className = 'absolute -top-2 -right-2 bg-white rounded-full p-1 shadow-md text-red-600 hover:text-red-800';
      removeBtn.innerHTML = '×';
      removeBtn.onclick = () => {
        preview.remove();
        if (this.previewTarget.children.length === 0) {
          this.reset();
        }
      }
      preview.appendChild(removeBtn);
    }

    reader.onerror = (e) => {
      console.error("Error reading file:", e);
    }

    reader.readAsDataURL(file);
    this.previewTarget.appendChild(preview);
  }

  reset() {
    console.log("Reset called");
    this.inputTarget.value = '';
    this.previewTarget.innerHTML = '';
    if (this.hasNoFileMessageTarget) {
      this.noFileMessageTarget.classList.remove('hidden');
    }
  }
}
