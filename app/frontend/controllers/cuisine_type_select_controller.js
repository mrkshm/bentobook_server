import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenInput", "results"]
  static values = { cuisineTypes: Array }

  connect() {
    if (!this.hasCuisineTypesValue) {
      console.error("Cuisine types data is missing")
      return
    }
    console.log("Cuisine types:", this.cuisineTypesValue)
    this.hideResultsTimeout = null
  }

  search() {
    const query = this.inputTarget.value.toLowerCase()
    const matches = this.cuisineTypesValue.filter(ct => 
      ct.name.toLowerCase().includes(query)
    )
    
    this.resultsTarget.innerHTML = matches.map(ct => `
      <li>
        <a href="#" data-action="mousedown->cuisine-type-select#select" data-id="${ct.id}" data-value="${ct.value}">
          ${ct.name}
        </a>
      </li>
    `).join('')

    this.showResults()
  }

  select(event) {
    event.preventDefault()
    const id = event.currentTarget.dataset.id
    const value = event.currentTarget.dataset.value
    const cuisineType = this.cuisineTypesValue.find(ct => ct.id === parseInt(id))
    
    this.hiddenInputTarget.value = value
    this.inputTarget.value = cuisineType.name
    this.hideResults()
  }

  showResults() {
    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }

  hideResultsDelayed() {
    this.hideResultsTimeout = setTimeout(() => {
      this.hideResults()
    }, 200)
  }

  showResultsImmediate() {
    clearTimeout(this.hideResultsTimeout)
    this.showResults()
  }
}