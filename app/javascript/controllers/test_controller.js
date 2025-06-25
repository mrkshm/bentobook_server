import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Test controller connected!', this.element)
  }

  log() {
    console.log('Test controller button clicked!')
  }
}
