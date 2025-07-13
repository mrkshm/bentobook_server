import { Controller } from "@hotwired/stimulus";

// location_controller
// --------------------
// Retrieves the user's current position using the browser Geolocation API once
// per day (cached in localStorage). When coordinates are acquired it ensures
// the surrounding form contains `latitude` and `longitude` hidden inputs and
// fills them.
//
// If the current sort field is `distance` and the form was waiting for
// coordinates, the form is auto-submitted so the request can include the new
// params.
export default class extends Controller {
  // This controller is now deprecated - use restaurant_sort_controller instead
  connect() {
    console.warn("location_controller is deprecated, please use restaurant_sort_controller")
  }

  // Helpers
  _ensureHiddenInput(name) {
    let input = this.element.querySelector(`input[name='${name}']`);
    if (!input) {
      input = document.createElement("input");
      input.type = "hidden";
      input.name = name;
      this.element.appendChild(input);
    }
    return input;
  }

  _applyCoords(lat, lng) {
    this.latInput.value = lat;
    this.lngInput.value = lng;
  }

  _readCache() {
    try {
      const data = JSON.parse(localStorage.getItem("coords"));
      if (data && Date.now() - data.ts < 24 * 60 * 60 * 1000) return data;
    } catch (_) {}
    return null;
  }

  _writeCache(lat, lng) {
    localStorage.setItem(
      "coords",
      JSON.stringify({ lat, lng, ts: Date.now() })
    );
  }

  _submitForm() {
    // Use the same submission logic as submit-on-change controller
    const form = this.element.closest('form') || this.element;
    if (!form || form.tagName !== 'FORM') {
      console.warn("Could not find form to submit for location controller");
      return;
    }

    const params = new URLSearchParams(new FormData(form)).toString();
    const url = form.getAttribute('action') || window.location.pathname;
    
    console.log("Submitting form with params:", params);
    Turbo.visit(`${url}?${params}`, { frame: "restaurants_page" });
  }
}
