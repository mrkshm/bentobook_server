import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  start() {
    // Preload the next page
    const url = this.element.href
    if (url) {
      const prefetchRequest = new Request(url, { headers: { Purpose: "prefetch" } })
      fetch(prefetchRequest)
    }
  }
}