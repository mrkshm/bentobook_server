import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  openModal(event) {
    const index = event.params.index
    const modal = document.getElementById(`gallery-modal-${index}`)
    const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
    if (modalController) {
      modalController.open()
    } else {
      console.error("Modal controller not found!")
    }
  }
}