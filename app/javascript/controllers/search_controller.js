import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clearButton", "searchIcon"]

  connect() {
    this.toggleClearButton()
  }

  toggleClearButton() {
    if (this.searchTarget.value) {
      this.clearButtonTarget.classList.remove('hidden')
      this.searchIconTarget?.classList.add('hidden')
    } else {
      this.clearButtonTarget.classList.add('hidden')
      this.searchIconTarget?.classList.remove('hidden')
    }
  }

  handleInput() {
    this.toggleClearButton()
  }

  clear() {
    this.searchTarget.value = ''
    this.searchTarget.focus()
    this.toggleClearButton()
    this.element.requestSubmit()
  }

  get searchTarget() {
    return this.element.querySelector('input[type="text"]')
  }
}
