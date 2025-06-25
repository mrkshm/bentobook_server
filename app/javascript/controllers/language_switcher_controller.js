import { Controller } from "@hotwired/stimulus"
import { visit } from "@hotwired/turbo"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.setupClickOutside()
  }

  disconnect() {
    if (this.clickOutsideHandler) {
      document.removeEventListener("click", this.clickOutsideHandler)
    }
  }

  toggleDropdown(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.menuTarget.classList.toggle("hidden")
    const isExpanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.buttonTarget.setAttribute("aria-expanded", !isExpanded)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }

  setupClickOutside() {
    this.clickOutsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
  }
}
