import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "previousButton", "nextButton"]
  static values = { 
    currentIndex: Number,
    totalCount: Number
  }

  connect() {
    this.currentIndexValue = 0
    document.addEventListener("keydown", this.handleKeydown.bind(this))
    console.log("Gallery connected, total images:", this.totalCountValue)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  openModal(event) {
    const index = parseInt(event.params.index)
    this.currentIndexValue = index
    console.log("Opening modal at index:", index, "of", this.totalCountValue)
    const modal = document.getElementById(`gallery-modal-${index}`)
    const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
    if (modalController) {
      modalController.open()
    }
  }

  next() {
    console.log("Next clicked, current index:", this.currentIndexValue, "total:", this.totalCountValue)
    if (this.currentIndexValue < this.totalCountValue - 1) {
      this.currentIndexValue++
      this.showCurrentImage()
    }
  }

  previous() {
    console.log("Previous clicked, current index:", this.currentIndexValue)
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.showCurrentImage()
    }
  }

  handleKeydown(event) {
    if (!this.modalIsOpen) return

    switch(event.key) {
      case "ArrowRight":
        this.next()
        break
      case "ArrowLeft":
        this.previous()
        break
      case "Escape":
        this.closeModal()
        break
    }
  }

  showCurrentImage() {
    console.log("Showing image at index:", this.currentIndexValue)
    
    // Close current modal
    const currentModal = document.querySelector('[data-controller="modal"]:not(.hidden)')
    if (currentModal) {
      const modalController = this.application.getControllerForElementAndIdentifier(currentModal, "modal")
      if (modalController) {
        modalController.close()
      }
    }

    // Open new modal
    const newModal = document.getElementById(`gallery-modal-${this.currentIndexValue}`)
    console.log("Opening new modal:", newModal?.id)
    const newModalController = this.application.getControllerForElementAndIdentifier(newModal, "modal")
    if (newModalController) {
      newModalController.open()
    }
  }

  get modalIsOpen() {
    return document.querySelector("[data-controller='modal']:not(.hidden)") !== null
  }
}