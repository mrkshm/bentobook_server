import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["readOnly", "editable"]

  toggleEdit() {
    this.readOnlyTarget.classList.toggle("hidden")
    this.editableTarget.classList.toggle("hidden")
  }
}