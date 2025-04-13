import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof window.isHotwireNativeApp !== 'undefined' && window.isHotwireNativeApp) {
      this.element.addEventListener('submit', this.handleSubmit.bind(this))
    }
  }

  disconnect() {
    if (typeof window.isHotwireNativeApp !== 'undefined' && window.isHotwireNativeApp) {
      this.element.removeEventListener('submit', this.handleSubmit.bind(this))
    }
  }

  handleSubmit(event) {
    // We'll handle the form submission in the standard way
    // but add a timestamp parameter to prevent caching
    const url = new URL(this.element.action, window.location.origin)
    url.searchParams.append('_t', Date.now())
    this.element.action = url.toString()
  }
}
