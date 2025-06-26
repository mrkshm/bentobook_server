import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.complete) {
      this.element.dispatchEvent(new Event('load'))
    }
  }
}