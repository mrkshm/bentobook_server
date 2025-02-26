import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    // Set initial validation if needed
  }

  validate() {
    const val = this.inputTarget.value.toUpperCase();
    const options = this.listTarget.options;
    let found = false;

    for (let i = 0; i < options.length; i++) {
      if (options[i].value.startsWith(val)) {
        found = true;
        break;
      }
    }

    if (!found && val.length > 0) {
      this.inputTarget.setCustomValidity(this.element.dataset.errorMessage || 'Please select a valid currency');
    } else {
      this.inputTarget.setCustomValidity('');
    }
  }
}