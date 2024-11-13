import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showMessage(event) {
    const message = event.currentTarget.dataset.message
    const flashDiv = document.getElementById('flash')
    
    flashDiv.innerHTML = `
      <div class="alert alert-success mb-4">
        <span>${message}</span>
      </div>
    `
  }
}