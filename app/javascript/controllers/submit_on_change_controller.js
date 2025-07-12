import { Controller } from "@hotwired/stimulus"

// Submits the form this controller is attached to when one of its child elements fires an event (e.g. change).
//
// Example:
//
// <form data-controller="submit-on-change" data-action="change->submit-on-change#submit">
//   <select name="sort">...</select>
// </form>
export default class extends Controller {
  submit() {
    const form = this.element.closest('form');
    if (!form) {
      console.warn("Could not find form to submit for submit-on-change controller");
      return;
    }

    const params = new URLSearchParams(new FormData(form)).toString();
    // We can't use form.action because the browser resolves it to a full URL,
    // and we need a path for Turbo.visit. We read it from the data attribute instead.
    const url = form.getAttribute('action');

    Turbo.visit(`${url}?${params}`, { frame: "restaurants_page" });
  }
}
