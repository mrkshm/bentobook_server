import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "sort", "orderAsc", "lat", "lng"]

  connect() {
    console.log("SortFormController connected")
  }

  // Called when sort selection changes
  async sortChanged(event) {
    console.log("Sort changed", event.target.value)
    
    if (event.target === this.sortTarget) {
      this.orderAscTarget.value = 'asc'
    }

    if (this.sortTarget.value === 'distance') {
      await this.handleLocationSort()
    } else {
      this.formTarget.submit()
    }
  }

  // Called when order direction changes
  orderChanged() {
    console.log("Order changed", this.orderAscTarget.value)
    this.formTarget.submit()
  }

  // Handle location-based sorting
  async handleLocationSort() {
    try {
      const position = await this.getCurrentPosition()
      
      this.latTarget.value = position.coords.latitude
      this.lngTarget.value = position.coords.longitude
      
      this.formTarget.submit()
    } catch (error) {
      console.error('Location error:', error)
      alert('Could not get your location. Please enable location services.')
      this.sortTarget.value = 'name'
      this.formTarget.submit()
    }
  }

  // Get current position wrapped in a Promise
  getCurrentPosition() {
    return new Promise((resolve, reject) => {
      navigator.geolocation.getCurrentPosition(resolve, reject)
    })
  }
}
