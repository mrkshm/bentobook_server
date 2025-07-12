import { Controller } from "@hotwired/stimulus"

/**
 * Debounce Controller
 * 
 * Automatically submits a form after a delay when the user stops typing.
 * 
 * @example
 * <form data-controller="debounce" data-action="input->debounce#submit">
 *   <input type="text" name="search">
 * </form>
 * 
 * @example With custom delay
 * <form data-controller="debounce" 
 *       data-debounce-delay-value="500"
 *       data-action="input->debounce#submit">
 *   <input type="text" name="search">
 * </form>
 */
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 300 }
  }

  initialize() {
    this.timeout = null
  }

  /**
   * Submit the form after the debounce delay
   * @param {Event} event - The input event
   */
  submit(event) {
    // Only process if the element is a form or has a form ancestor
    const form = this.element.tagName === 'FORM' 
      ? this.element 
      : this.element.closest('form')
    
    if (!form || typeof form.requestSubmit !== 'function') {
      console.warn('Debounce controller: Could not find form to submit')
      return
    }

    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      const params = new URLSearchParams(new FormData(form)).toString();
      const url = form.getAttribute('action');
      Turbo.visit(`${url}?${params}`, { frame: "restaurants_page" });
    }, this.delayValue)
  }

  /**
   * Clean up any pending timeouts when the controller is disconnected
   */
  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}