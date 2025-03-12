import { Controller } from "@hotwired/stimulus"

function extractAddressFromGooglePlace(place) {
  if (!place.address_components) {
    console.log("No address components");
    return {};
  }
  
  const address = {};
  place.address_components.forEach(function(component) {
    const type = component.types[0];
    switch (type) {
      case "street_number":
        address.street_number = component.long_name;
        break;
      case "route":
        address.street_name = component.long_name;
        break;
      case "administrative_area_level_1":
        address.state = component.long_name;
        break;
      case "postal_code":
        address.postal_code = component.long_name;
        break;
      case "locality":
        address.city = component.long_name;
        break;
      case "country":
        address.country = component.long_name;
        break;
    }
  });

  return address;
}

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // If Google is already loaded, initialize immediately
    if (window.google && window.google.maps && window.google.maps.places) {
      this.initializeAutocomplete()
    } else {
      // If not loaded yet, set up the callback
      window.initGooglePlaces = () => {
        // Initialize all places-autocomplete controllers
        document.querySelectorAll('[data-controller="places-autocomplete"]').forEach(element => {
          const controller = this.application.getControllerForElementAndIdentifier(element, 'places-autocomplete')
          if (controller) {
            controller.initializeAutocomplete()
          }
        })
      }
    }
  }

  initializeAutocomplete() {
    if (!window.google || !window.google.maps || !window.google.maps.places) {
      console.warn('Google Maps API not loaded yet')
      return
    }

    this.autocomplete = new google.maps.places.Autocomplete(this.element, {
      types: ['establishment']
    })
    this.autocomplete.addListener("place_changed", this.placeSelected.bind(this))
  }

  reset() {
    this.element.value = ""
    this.element.disabled = false
  }

  placeSelected() {
    const place = this.autocomplete.getPlace()
    if (!place.place_id) return

    const addressData = extractAddressFromGooglePlace(place)
    
    const placeData = {
      place: {
        google_place_id: place.place_id,
        name: place.name,
        latitude: place.geometry?.location?.lat(),
        longitude: place.geometry?.location?.lng(),
        formatted_address: place.formatted_address,
        phone_number: place.formatted_phone_number,
        website: place.website,
        rating: place.rating,
        user_ratings_total: place.user_ratings_total,
        price_level: place.price_level,
        business_status: place.business_status,
        street_number: addressData.street_number,
        street_name: addressData.route || addressData.street_name,
        city: addressData.locality || addressData.city,
        state: addressData.administrative_area_level_1 || addressData.state,
        postal_code: addressData.postal_code,
        country: addressData.country
      }
    }

    fetch('/restaurants/new/confirm', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(placeData)
    })
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok')
      return response.text()
    })
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error("Error loading restaurant form:", error)
      const errorDiv = document.createElement('div')
      errorDiv.className = 'text-[var(--color-error-700)] bg-[var(--color-error-100)] p-4 rounded-md'
      errorDiv.textContent = "Could not load restaurant details. Please try again."
      document.getElementById("restaurant_form").innerHTML = errorDiv.outerHTML
    })
  }

  get locale() {
    return document.documentElement.lang || "en"
  }
}
