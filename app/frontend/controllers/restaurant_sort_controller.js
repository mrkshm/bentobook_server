import { Controller } from "@hotwired/stimulus"

// Restaurant Sort Controller - Clean Vite version
export default class extends Controller {
  static targets = ["sortField"]
  static values = { 
    url: String,
    frame: { type: String, default: "restaurants_page" }
  }

  connect() {
    console.log("🎯 Restaurant sort controller connected via Vite!")
    console.log("Element:", this.element)
    console.log("URL value:", this.urlValue)
    console.log("Frame value:", this.frameValue)
    
    if (this.hasSortFieldTarget) {
      console.log("Sort field found:", this.sortFieldTarget.value)
      // Don't auto-handle distance on connect to avoid infinite loops
      // Only handle on user interaction (sortFieldChanged)
    }
  }

  sortFieldChanged(event) {
    console.log("🔄 Sort field changed to:", event.target.value)
    
    if (event.target.value === "distance") {
      this.handleDistanceSorting()
    } else {
      this.submitForm()
    }
  }

  sortDirectionChanged(event) {
    const nextDirection = event.target?.value
    console.log("🔄 Sort direction changed to:", nextDirection)

    // Ensure hidden field reflects the chosen direction so programmatic submits include it
    const hidden = this.element.querySelector('input[name="order_direction"]')
    if (hidden && nextDirection) hidden.value = nextDirection

    if (this.hasSortFieldTarget && this.sortFieldTarget.value === "distance") {
      // Avoid double-submitting; we'll submit programmatically after possibly adding location
      event.preventDefault()
      this.handleDistanceSorting()
    }
    // For non-distance sorting, let the normal form submission happen
  }

  async handleDistanceSorting() {
    console.log("📍 Handling distance sorting...")
    
    try {
      const coords = await this.getLocation()
      console.log("Got coordinates:", coords)
      this.addLocationToForm(coords)
      this.submitForm()
    } catch (error) {
      console.log("Location error:", error.message)
      // Submit without location
      this.submitForm()
    }
  }

  async getLocation() {
    // Try cached coordinates first
    const cached = this.getCachedLocation()
    if (cached) {
      console.log("Using cached location:", cached)
      return cached
    }

    // Request fresh location
    console.log("🗺️ Requesting location permission...")
    return new Promise((resolve, reject) => {
      if (!("geolocation" in navigator)) {
        reject(new Error("Geolocation not available"))
        return
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const coords = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude
          }
          this.cacheLocation(coords)
          resolve(coords)
        },
        (error) => {
          reject(new Error(`Geolocation failed: ${error.message}`))
        },
        { 
          enableHighAccuracy: false, 
          maximumAge: 30000, 
          timeout: 10000 
        }
      )
    })
  }

  addLocationToForm(coords) {
    // Remove existing location inputs
    this.element.querySelectorAll('input[name="latitude"], input[name="longitude"]').forEach(input => {
      input.remove()
    })
    
    // Add new hidden inputs
    const latInput = document.createElement("input")
    latInput.type = "hidden"
    latInput.name = "latitude"
    latInput.value = coords.latitude
    this.element.appendChild(latInput)
    
    const lngInput = document.createElement("input")
    lngInput.type = "hidden"
    lngInput.name = "longitude"
    lngInput.value = coords.longitude
    this.element.appendChild(lngInput)
    
    console.log("📌 Added location to form:", coords)
  }

  submitForm() {
    const formData = new FormData(this.element)
    const params = new URLSearchParams(formData).toString()
    const url = this.urlValue || this.element.action || window.location.pathname
    
    console.log("🚀 Submitting form:", `${url}?${params}`)
    
    // Use Turbo frame navigation
    Turbo.visit(`${url}?${params}`, { frame: this.frameValue })
  }

  // Cache management
  getCachedLocation() {
    try {
      const cached = localStorage.getItem("restaurant_location")
      if (!cached) return null
      
      const data = JSON.parse(cached)
      const age = Date.now() - data.timestamp
      const maxAge = 24 * 60 * 60 * 1000 // 24 hours
      
      return age < maxAge ? { latitude: data.latitude, longitude: data.longitude } : null
    } catch {
      return null
    }
  }

  cacheLocation(coords) {
    try {
      const data = {
        latitude: coords.latitude,
        longitude: coords.longitude,
        timestamp: Date.now()
      }
      localStorage.setItem("restaurant_location", JSON.stringify(data))
    } catch (error) {
      console.log("Failed to cache location:", error)
    }
  }
}