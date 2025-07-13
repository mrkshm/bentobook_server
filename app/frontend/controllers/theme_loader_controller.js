import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const storedTheme = localStorage.getItem('theme') || 'light'
    document.documentElement.setAttribute('data-theme', storedTheme)
  }
}
