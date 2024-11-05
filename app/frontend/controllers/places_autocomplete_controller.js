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

  placeSelected() {
    const place = this.autocomplete.getPlace();
    const form = document.querySelector('#restaurant-form form');

    if (!place.geometry) {
      console.error('No details available for input: ' + place.name);
      return;
    }

    const extractedAddress = extractAddressFromGooglePlace(place);
    const service = new google.maps.places.PlacesService(document.createElement('div'));
    
    service.getDetails(
      {
        placeId: place.place_id,
        fields: [
          'name',
          'formatted_address',
          'formatted_phone_number',
          'website',
          'business_status',
          'price_level',
          'rating',
          'user_ratings_total',
          'geometry',
          'opening_hours',
          'address_components',
          'place_id'
        ]
      },
      (detailedPlace, status) => {
        if (status === google.maps.places.PlacesServiceStatus.OK) {
          const extractedAddress = extractAddressFromGooglePlace(detailedPlace);
          const openingHours = detailedPlace.opening_hours ? {
            isOpen: detailedPlace.opening_hours.isOpen(),
            periods: detailedPlace.opening_hours.periods,
            weekday_text: detailedPlace.opening_hours.weekday_text
          } : null;

          form.querySelector('#restaurant_name').value = detailedPlace.name;
          form.querySelector('#restaurant_address').value = detailedPlace.formatted_address;
          form.querySelector('#restaurant_street_number').value = extractedAddress.street_number || '';
          form.querySelector('#restaurant_street').value = extractedAddress.street_name || '';
          form.querySelector('#restaurant_postal_code').value = extractedAddress.postal_code || '';
          form.querySelector('#restaurant_city').value = extractedAddress.city || '';
          form.querySelector('#restaurant_state').value = extractedAddress.state || '';
          form.querySelector('#restaurant_country').value = extractedAddress.country || '';
          form.querySelector('#restaurant_phone_number').value = detailedPlace.formatted_phone_number || '';
          form.querySelector('#restaurant_url').value = detailedPlace.website || '';
          form.querySelector('#restaurant_business_status').value = detailedPlace.business_status || '';
          form.querySelector('#restaurant_price_level').value = detailedPlace.price_level || '';

          form.querySelector('#restaurant_google_restaurant_attributes_google_place_id').value = detailedPlace.place_id || '';
          form.querySelector('#restaurant_google_restaurant_attributes_name').value = detailedPlace.name;
          form.querySelector('#restaurant_google_restaurant_attributes_address').value = detailedPlace.formatted_address;
          form.querySelector('#restaurant_google_restaurant_attributes_latitude').value = detailedPlace.geometry.location.lat();
          form.querySelector('#restaurant_google_restaurant_attributes_longitude').value = detailedPlace.geometry.location.lng();
          form.querySelector('#restaurant_google_restaurant_attributes_street_number').value = extractedAddress.street_number || '';
          form.querySelector('#restaurant_google_restaurant_attributes_street').value = extractedAddress.street_name || '';
          form.querySelector('#restaurant_google_restaurant_attributes_postal_code').value = extractedAddress.postal_code || '';
          form.querySelector('#restaurant_google_restaurant_attributes_city').value = extractedAddress.city || '';
          form.querySelector('#restaurant_google_restaurant_attributes_state').value = extractedAddress.state || '';
          form.querySelector('#restaurant_google_restaurant_attributes_country').value = extractedAddress.country || '';
          form.querySelector('#restaurant_google_restaurant_attributes_phone_number').value = detailedPlace.formatted_phone_number || '';
          form.querySelector('#restaurant_google_restaurant_attributes_url').value = detailedPlace.website || '';
          form.querySelector('#restaurant_google_restaurant_attributes_business_status').value = detailedPlace.business_status || '';
          form.querySelector('#restaurant_google_restaurant_attributes_google_rating').value = detailedPlace.rating || '';
          form.querySelector('#restaurant_google_restaurant_attributes_google_ratings_total').value = detailedPlace.user_ratings_total || '';
          form.querySelector('#restaurant_google_restaurant_attributes_price_level').value = detailedPlace.price_level || '';
          form.querySelector('#restaurant_google_restaurant_attributes_opening_hours').value = 
            openingHours ? JSON.stringify(openingHours) : '';
          form.querySelector('#restaurant_google_restaurant_attributes_google_updated_at').value = new Date().toISOString();

          // Dispatch the place-selected event
          const placeSelectedEvent = new CustomEvent('place-selected', { 
            bubbles: true,
            detail: { place }
          });
          window.dispatchEvent(placeSelectedEvent);

          // Update display values immediately
          if (typeof updateDisplayValues === 'function') {
            updateDisplayValues();
          }
        }
      }
    );
  }
}
