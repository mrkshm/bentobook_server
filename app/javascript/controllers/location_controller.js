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
  connect() {
    const fieldSelect = this.element.querySelector("select[name='field']");
    
    // If distance is already selected on page load
    if (fieldSelect && fieldSelect.value === "distance") {
      this.initializeLocation();
    }
    
    // Watch for changes to the select field
    if (fieldSelect) {
      fieldSelect.addEventListener("change", (e) => {
        if (e.target.value === "distance") {
          this.initializeLocation();
        }
      });
    }
  }

  initializeLocation() {
    // Prepare (or create) hidden inputs
    this.latInput = this._ensureHiddenInput("latitude");
    this.lngInput = this._ensureHiddenInput("longitude");

    // Do nothing if we already have coords
    if (this.latInput.value && this.lngInput.value) return;

    // Try cached coordinates (valid for 24h)
    const cached = this._readCache();
    if (cached) {
      this._applyCoords(cached.lat, cached.lng);
      return;
    }

    // Request fresh position
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const { latitude, longitude } = pos.coords;
          this._applyCoords(latitude, longitude);
          this._writeCache(latitude, longitude);

          // Auto-submit if sorting by distance
          const fieldSelect = this.element.querySelector("select[name='field']");
          if (fieldSelect && fieldSelect.value === "distance") {
            this.element.requestSubmit();
          }
        },
        () => {
          /* user denied or error – nothing to do */
        },
        { enableHighAccuracy: false, maximumAge: 30000, timeout: 10000 }
      );
    }
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
}
