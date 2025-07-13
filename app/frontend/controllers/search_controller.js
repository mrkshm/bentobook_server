import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clearButton", "searchIcon", "input"]

  connect() {
    if (this.hasInputTarget) {
      this.toggleClearButton()
    }
  }

  toggleClearButton() {
    if (!this.hasInputTarget) return
    
    if (this.inputTarget.value) {
      this.hasClearButtonTarget && this.clearButtonTarget.classList.remove('hidden')
      this.hasSearchIconTarget && this.searchIconTarget.classList.add('hidden')
    } else {
      this.hasClearButtonTarget && this.clearButtonTarget.classList.add('hidden')
      this.hasSearchIconTarget && this.searchIconTarget.classList.remove('hidden')
    }
  }

  handleInput() {
    this.toggleClearButton()
  }

  clear() {
    if (!this.hasInputTarget) return
    
    this.inputTarget.value = ''
    this.inputTarget.focus()
    this.toggleClearButton()
    this.element.requestSubmit()
  }
}
