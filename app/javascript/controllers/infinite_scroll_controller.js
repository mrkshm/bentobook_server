import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pagination"]
  
  initialize() {
    this.scroll = this.scroll.bind(this)
    this.intersectionObserver = null
  }

  connect() {
    if (this.hasPaginationTarget) {
      this.observe()
    }
  }

  disconnect() {
    this.unobserve()
  }

  observe() {
    if (!this.intersectionObserver && this.hasPaginationTarget) {
      this.intersectionObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            this.loadMore()
          }
        })
      }, {
        rootMargin: '200px',
        threshold: 0.1
      })
      
      this.intersectionObserver.observe(this.paginationTarget)
    }
  }

  unobserve() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect()
      this.intersectionObserver = null
    }
  }

  loadMore() {
    const nextUrl = this.paginationTarget.dataset.infiniteScrollNextUrl
    if (!nextUrl) return

    this.unobserve()
    
    fetch(nextUrl, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error loading more restaurants:', error)
      this.observe() // Re-observe on error
    })
  }
}
