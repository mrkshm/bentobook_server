import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    console.log("MobileMenuController connected")
    // Handle clicking outside to close menu
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    console.log("MobileMenuController disconnected")
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  toggle() {
    console.log("Toggle called")
    console.log("Menu target:", this.menuTarget)
    console.log("Button target:", this.buttonTarget)
    this.menuTarget.classList.toggle("hidden")
    const isExpanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.buttonTarget.setAttribute("aria-expanded", !isExpanded)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }
}
