import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Debug form controller connected")
    this.element.addEventListener('submit', this.handleSubmit.bind(this))
  }

  handleSubmit(event) {
    console.log("Form submitting...")
    const formData = new FormData(event.target)
    for (let [key, value] of formData.entries()) {
      console.log(`${key}:`, value instanceof File ? `File: ${value.name}` : value)
    }
    return true
  }
}