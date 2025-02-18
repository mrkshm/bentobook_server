import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "sort", "orderAsc", "lat", "lng"]

  // Called when sort selection changes
  async sortChanged(event) {
    if (event.target === this.sortTarget) {
      this.orderAscTarget.value = 'asc'
    }

    if (this.sortTarget.value === 'distance') {
      await this.handleLocationSort()
    } else {
      // Clear location data if not sorting by distance
      this.latTarget.value = ''
      this.lngTarget.value = ''
      this.submitForm()
    }
  }

  // Called when order direction changes
  orderChanged() {
    this.submitForm()
  }

  // Handle location-based sorting
  async handleLocationSort() {
    try {
      // Show loading state
      this.sortTarget.disabled = true
      this.orderAscTarget.disabled = true
      
      const position = await this.getCurrentPosition()
      
      // Set form values
      this.latTarget.value = position.coords.latitude
      this.lngTarget.value = position.coords.longitude
      this.sortTarget.value = 'distance'
      
      this.submitForm()
    } catch (error) {
      let errorMessage = 'Could not get your location. '
      
      switch(error.code) {
        case 1: // PERMISSION_DENIED
          errorMessage += 'Please allow location access in your browser settings and try again.'
          break
        case 2: // POSITION_UNAVAILABLE
          errorMessage += 'Location information is currently unavailable. Please try again.'
          break
        case 3: // TIMEOUT
          errorMessage += 'Getting location timed out. Please try again.'
          break
        default:
          errorMessage += error.message || 'Please try again.'
      }

      alert(errorMessage)
      this.sortTarget.value = 'name'
      this.submitForm()
    } finally {
      // Re-enable controls
      this.sortTarget.disabled = false
      this.orderAscTarget.disabled = false
    }
  }

  // Submit form preserving all values
  submitForm() {
    const params = new URLSearchParams({
      order_by: this.sortTarget.value,
      order_direction: this.orderAscTarget.value
    })

    if (this.latTarget.value && this.lngTarget.value) {
      params.append('latitude', this.latTarget.value)
      params.append('longitude', this.lngTarget.value)
    }

    window.location.href = `${this.formTarget.action}?${params.toString()}`
  }

  // Get current position wrapped in a Promise
  getCurrentPosition() {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject(new Error('Geolocation is not supported by your browser'))
        return
      }

      navigator.geolocation.getCurrentPosition(
        resolve,
        reject,
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0
        }
      )
    })
  }
}
