import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview", "hiddenInput"];

  connect() {
    console.log("ImagePreviewController connected");
    this.selectedFiles = [];
    this.inputTarget.addEventListener("change", this.previewImages.bind(this));
  }

  previewImages() {
    const files = this.inputTarget.files;
    this.selectedFiles = [...this.selectedFiles, ...files];
    this.renderPreviews();
    this.updateHiddenInput();
  }

  renderPreviews() {
    this.previewTarget.innerHTML = "";
    this.selectedFiles.forEach((file, index) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const imgContainer = document.createElement("div");
        imgContainer.style.position = "relative";
        imgContainer.style.display = "inline-block";
        imgContainer.style.marginRight = "10px";

        const img = document.createElement("img");
        img.src = event.target.result;
        img.style.width = "100px";
        img.style.marginRight = "10px";
        imgContainer.appendChild(img);

        const deleteButton = document.createElement("button");
        deleteButton.innerText = "X";
        deleteButton.style.position = "absolute";
        deleteButton.style.top = "40px";
        deleteButton.style.right = "16px";
        deleteButton.style.width = "20px";
        deleteButton.style.height = "20px";
        deleteButton.style.backgroundColor = "red";
        deleteButton.style.color = "white";
        deleteButton.style.border = "none";
        deleteButton.style.cursor = "pointer";
        deleteButton.style.padding = "0";
        deleteButton.style.borderRadius = "50%";
        deleteButton.style.fontSize = "12px";
        deleteButton.title = "Remove this image";
        deleteButton.onclick = () => {
          this.removeFile(index);
        };

        imgContainer.appendChild(deleteButton);
        this.previewTarget.appendChild(imgContainer);
      };
      reader.readAsDataURL(file);
    });
  }

  updateHiddenInput() {
    const dataTransfer = new DataTransfer();
    this.selectedFiles.forEach(file => dataTransfer.items.add(file));
    this.hiddenInputTarget.files = dataTransfer.files;
  }

  removeFile(index) {
    this.selectedFiles.splice(index, 1);
    this.renderPreviews();
    this.updateHiddenInput();
  }

  reset() {
    this.selectedFiles = [];
    this.inputTarget.value = "";
    this.hiddenInputTarget.value = "";
    this.previewTarget.innerHTML = "";
  }

  triggerFileInput() {
    this.inputTarget.click();
  }
}