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
    if (window.google && window.google.maps) {
      this.initAutocomplete();
    } else {
      window.addEventListener('load', () => this.initAutocomplete());
    }
  }

  initAutocomplete() {
    this.autocomplete = new google.maps.places.Autocomplete(this.element, {
      types: ['establishment']
    });
    this.autocomplete.addListener("place_changed", this.placeSelected.bind(this));
  }

  placeSelected() {
    const place = this.autocomplete.getPlace();
    const form = this.element.closest('form');

    if (!place.geometry) {
      console.error('No details available for input: ' + place.name);
      return;
    }

    const extractedAddress = extractAddressFromGooglePlace(place);

    // Populate restaurant fields
    form.querySelector('#restaurant_name').value = place.name;
    form.querySelector('#restaurant_address').value = place.formatted_address;
    form.querySelector('#restaurant_street_number').value = extractedAddress.street_number || '';
    form.querySelector('#restaurant_street').value = extractedAddress.street_name || '';
    form.querySelector('#restaurant_postal_code').value = extractedAddress.postal_code || '';
    form.querySelector('#restaurant_city').value = extractedAddress.city || '';
    form.querySelector('#restaurant_state').value = extractedAddress.state || '';
    form.querySelector('#restaurant_country').value = extractedAddress.country || '';
    form.querySelector('#restaurant_phone_number').value = place.formatted_phone_number || '';
    form.querySelector('#restaurant_url').value = place.website || '';
    form.querySelector('#restaurant_business_status').value = place.business_status || '';
    form.querySelector('#restaurant_price_level').value = place.price_level || '';

    // Populate google_restaurant_attributes fields
    form.querySelector('#restaurant_google_restaurant_attributes_google_place_id').value = place.place_id;
    form.querySelector('#restaurant_google_restaurant_attributes_name').value = place.name;
    form.querySelector('#restaurant_google_restaurant_attributes_address').value = place.formatted_address;
    form.querySelector('#restaurant_google_restaurant_attributes_latitude').value = place.geometry.location.lat();
    form.querySelector('#restaurant_google_restaurant_attributes_longitude').value = place.geometry.location.lng();
    form.querySelector('#restaurant_google_restaurant_attributes_street_number').value = extractedAddress.street_number || '';
    form.querySelector('#restaurant_google_restaurant_attributes_street').value = extractedAddress.street_name || '';
    form.querySelector('#restaurant_google_restaurant_attributes_postal_code').value = extractedAddress.postal_code || '';
    form.querySelector('#restaurant_google_restaurant_attributes_city').value = extractedAddress.city || '';
    form.querySelector('#restaurant_google_restaurant_attributes_state').value = extractedAddress.state || '';
    form.querySelector('#restaurant_google_restaurant_attributes_country').value = extractedAddress.country || '';
    form.querySelector('#restaurant_google_restaurant_attributes_phone_number').value = place.formatted_phone_number || '';
    form.querySelector('#restaurant_google_restaurant_attributes_url').value = place.website || '';
    form.querySelector('#restaurant_google_restaurant_attributes_business_status').value = place.business_status || '';
    form.querySelector('#restaurant_google_restaurant_attributes_google_rating').value = place.rating || '';
    form.querySelector('#restaurant_google_restaurant_attributes_google_ratings_total').value = place.user_ratings_total || '';
    form.querySelector('#restaurant_google_restaurant_attributes_price_level').value = place.price_level || '';
    form.querySelector('#restaurant_google_restaurant_attributes_opening_hours').value = JSON.stringify(place.opening_hours) || '';
    form.querySelector('#restaurant_google_restaurant_attributes_google_updated_at').value = new Date().toISOString();

    console.log('Place selected:', place);
    console.log('Extracted address:', extractedAddress);
  }
}