import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    // Ensure list is visible when controller connects
    if (this.hasListTarget) {
      this.listTarget.style.display = ''
    }

    // Listen for Turbo events
    document.addEventListener("turbo:before-cache", this.beforeCache.bind(this))
    document.addEventListener("turbo:before-render", this.beforeRender.bind(this))
    document.addEventListener("turbo:render", this.render.bind(this))
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("turbo:before-cache", this.beforeCache.bind(this))
    document.removeEventListener("turbo:before-render", this.beforeRender.bind(this))
    document.removeEventListener("turbo:render", this.render.bind(this))
  }

  beforeCache() {
    // Don't cache the list state
    if (this.hasListTarget) {
      this.listTarget.style.display = ''
    }
  }

  beforeRender() {
    // Ensure list is visible before rendering
    if (this.hasListTarget) {
      this.listTarget.style.display = ''
    }
  }

  render() {
    // Ensure list is visible after rendering
    if (this.hasListTarget) {
      this.listTarget.style.display = ''
    }
  }
}
