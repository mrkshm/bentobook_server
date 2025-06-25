import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    currentTheme: String,
    themePath: String  // This needs to match the data attribute we send
  }

  hasInitialized = false

  static targets = ["button"]

  connect() {
    if (this.hasInitialized) return
    this.hasInitialized = true
    
    const storedTheme = localStorage.getItem('theme')
    const theme = storedTheme || this.currentThemeValue || 'light'
    this.setTheme(theme, false) // Don't sync with server on initial load
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light'
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    this.setTheme(newTheme, true)
  }

  setTheme(theme, syncWithServer = true) {
    console.log('Setting theme:', theme)
    document.documentElement.setAttribute('data-theme', theme)
    document.body.setAttribute('data-theme', theme)
    localStorage.setItem('theme', theme)
    this.updateIcon(theme)
    
    if (syncWithServer && this.hasThemePathValue) {  // Check if we have the path
      console.log('Theme path:', this.themePathValue)  // Debug log
      this.syncThemeWithServer(theme)
    }
  }

  syncThemeWithServer(theme) {
    fetch(this.themePathValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ theme })
    })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      return response.json()
    })
    .catch(error => console.error('Theme sync error:', error))
  }

  disconnect() {
    this.hasInitialized = false
  }

  updateIcon(theme) {
    console.log('Updating icon for theme:', theme)
    this.element.innerHTML = theme === 'light' ? this.darkIcon : this.lightIcon
    this.element.setAttribute(
      'aria-label',
      `Switch to ${theme === 'light' ? 'dark' : 'light'} theme`
    )
  }

  get darkIcon() {
    return `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
    </svg>`
  }

  get lightIcon() {
    return `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
    </svg>`
  }
}