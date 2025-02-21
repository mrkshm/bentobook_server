import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "editor", "textarea", "editButton", "addButton", "saveButton", "cancelButton"]
  static values = {
    url: String,
    content: String
  }

  connect() {
    this.isEditing = false
    console.log("🗒️ Note editor controller connected", {
      targets: this.targets,
      values: {
        content: this.contentValue,
        url: this.urlValue
      }
    })
  }

  toggleEdit(event) {
    event.preventDefault()
    if (this.isEditing) {
      this.hideEditor()
    } else {
      this.showEditor()
    }
    this.isEditing = !this.isEditing
  }

  showEditor(event) {
    if (event) event.preventDefault()
    
    if (this.hasDisplayTarget) {
      this.displayTarget.classList.add("hidden")
    }
    if (this.hasAddButtonTarget) {
      this.addButtonTarget.classList.add("hidden")
    }
    if (this.hasEditButtonTarget) {
      this.editButtonTarget.classList.add("hidden")
    }
    
    this.editorTarget.classList.remove("hidden")
    this.textareaTarget.value = this.contentValue || ""
    this.textareaTarget.focus()
    this.isEditing = true
  }

  hideEditor() {
    if (this.hasDisplayTarget) {
      this.displayTarget.classList.remove("hidden")
    }
    if (this.hasAddButtonTarget && !this.contentValue) {
      this.addButtonTarget.classList.remove("hidden")
    }
    if (this.hasEditButtonTarget && this.contentValue) {
      this.editButtonTarget.classList.remove("hidden")
    }
    
    this.editorTarget.classList.add("hidden")
    this.isEditing = false
  }

  cancel(event) {
    event.preventDefault()
    this.hideEditor()
  }

  save(event) {
    event.preventDefault()
    const formData = new FormData()
    // Match the field name with what the controller expects
    formData.append("restaurant[notes]", this.textareaTarget.value)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html, application/json"
      },
      body: formData
    })
    .then(response => {
      if (!response.ok) throw new Error("Network response was not ok")
      return response.text()
    })
    .then(html => {
      if (html.includes("turbo-stream")) {
        Turbo.renderStreamMessage(html)
      } else {
        // If not a turbo-stream, update manually
        this.contentValue = this.textareaTarget.value
        if (this.hasDisplayTarget) {
          this.displayTarget.textContent = this.textareaTarget.value
        }
      }
      this.hideEditor()
    })
    .catch(error => {
      console.error("Error saving notes:", error)
      // TODO: Add error notification
    })
  }
}