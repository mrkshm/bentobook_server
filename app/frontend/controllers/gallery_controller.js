import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "previousButton", "nextButton", "loader", "currentImage"]
  static values = { 
    currentIndex: Number,
    totalCount: Number
  }

  connect() {
    this.currentIndexValue = 0
    document.addEventListener("keydown", this.handleKeydown.bind(this))
    this.setupTouchHandlers()
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
    this.removeTouchHandlers()
  }

  setupTouchHandlers() {
    // Store bound handlers so we can remove them later
    this.touchStartHandler = this.handleTouchStart.bind(this)
    this.touchEndHandler = this.handleTouchEnd.bind(this)
    this.touchMoveHandler = this.handleTouchMove.bind(this)

    document.addEventListener('touchstart', this.touchStartHandler, { passive: true })
    document.addEventListener('touchend', this.touchEndHandler)
    document.addEventListener('touchmove', this.touchMoveHandler, { passive: true })
  }

  removeTouchHandlers() {
    document.removeEventListener('touchstart', this.touchStartHandler)
    document.removeEventListener('touchend', this.touchEndHandler)
    document.removeEventListener('touchmove', this.touchMoveHandler)
  }

  handleTouchStart(event) {
    if (!this.modalIsOpen) return

    this.touchStartX = event.touches[0].clientX
    this.touchStartY = event.touches[0].clientY
    this.touchMoved = false
  }

  handleTouchMove(event) {
    if (!this.modalIsOpen || !this.touchStartX) return

    this.touchMoved = true
    this.currentTouchX = event.touches[0].clientX
    this.currentTouchY = event.touches[0].clientY
  }

  handleTouchEnd(event) {
    if (!this.modalIsOpen || !this.touchMoved) return

    const touchEndX = event.changedTouches[0].clientX
    const touchEndY = event.changedTouches[0].clientY
    
    // Calculate distances
    const deltaX = touchEndX - this.touchStartX
    const deltaY = touchEndY - this.touchStartY
    
    // Only handle horizontal swipes (ignore vertical scrolling)
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      const swipeThreshold = 50 // minimum distance for a swipe
      
      if (Math.abs(deltaX) > swipeThreshold) {
        if (deltaX > 0 && this.currentIndexValue > 0) {
          // Swiped right -> show previous
          this.previous()
        } else if (deltaX < 0 && this.currentIndexValue < this.totalCountValue - 1) {
          // Swiped left -> show next
          this.next()
        }
      }
    }

    // Reset touch tracking
    this.touchStartX = null
    this.touchStartY = null
    this.touchMoved = false
  }

  openModal(event) {
    const index = parseInt(event.params.index)
    this.currentIndexValue = index
    const modal = document.getElementById(`gallery-modal-${index}`)
    const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
    if (modalController) {
      modalController.open()
    }
  }

  next() {
    if (this.currentIndexValue < this.totalCountValue - 1) {
      this.currentIndexValue++
      this.showCurrentImage()
    }
  }

  previous() {
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
        event.preventDefault()
        event.stopPropagation()
        break
    }
  }

  showCurrentImage() {
    // Close current modal
    const currentModal = document.querySelector('[data-controller="modal"]:not(.hidden)')
    if (currentModal) {
      const modalController = this.application.getControllerForElementAndIdentifier(currentModal, "modal")
      if (modalController) {
        modalController.close()
      }
    }

    // Open new modal and show loading state
    const newModal = document.getElementById(`gallery-modal-${this.currentIndexValue}`)
    if (!newModal) return

    const newModalController = this.application.getControllerForElementAndIdentifier(newModal, "modal")
    if (newModalController) {
      this.showLoading(newModal)
      newModalController.open()
    }
  }

  imageLoaded(event) {
    const image = event.target
    const modal = image.closest('[data-controller="modal"]')
    
    if (!modal) return

    const loader = modal.querySelector('[data-gallery-target="loader"]')
    const currentImage = modal.querySelector('[data-gallery-target="currentImage"]')

    if (!loader || !currentImage) return
    
    // Force a reflow to ensure the transition works
    void loader.offsetWidth
    
    // Show the image
    currentImage.style.opacity = '1'
    
    // Hide the loader
    loader.style.opacity = '0'
    
    // Remove the loader after transition
    setTimeout(() => {
      loader.style.display = 'none'
    }, 300)
  }

  imageError(event) {
    const loader = this.loaderTarget
    loader.style.display = 'flex'
    
    // Show error state instead of spinner
    loader.innerHTML = `
      <div class="text-center text-white">
        <svg class="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <p class="mt-2">Failed to load image</p>
      </div>`
  }

  showLoading(modal) {
    const loader = modal.querySelector('[data-gallery-target="loader"]')
    const currentImage = modal.querySelector('[data-gallery-target="currentImage"]')
    
    if (!loader || !currentImage) return

    // Reset the image
    currentImage.style.opacity = '0'
    
    // Show the loader
    loader.style.display = 'flex'
    loader.style.opacity = '1'
    
    // Force image reload by updating the src
    const originalSrc = currentImage.src
    currentImage.src = ''
    currentImage.src = originalSrc
  }

  findLoader(element) {
    return element.closest('[data-controller="modal"]')?.querySelector('[data-gallery-target="loader"]')
  }

  get modalIsOpen() {
    return document.querySelector("[data-controller='modal']:not(.hidden)") !== null
  }
}