import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.updateActiveState()
  }

  toggle(event) {
    this.buttonTargets.forEach(btn => {
      btn.classList.remove('btn-secondary')
    })
    
    event.currentTarget.classList.add('btn-secondary')
  }

  updateActiveState() {
    const checkedInput = this.element.querySelector('input[type="radio"]:checked')
    if (checkedInput) {
      const label = checkedInput.closest('label')
      if (label) {
        label.classList.add('btn-secondary')
      }
    }
  }
}
