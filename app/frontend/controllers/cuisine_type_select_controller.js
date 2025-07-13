import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenInput", "results"]
  static values = { cuisineTypes: Array }

  connect() {
    if (!this.hasCuisineTypesValue) {
      console.error("Cuisine types data is missing")
      return
    }
    this.hideResultsTimeout = null
    this.renderAllCategories()
  }

  // Render all categories with their cuisine types
  renderAllCategories() {
    const html = this.cuisineTypesValue.map(category => `
      <li class="menu-title pt-0">${category.name}</li>
      ${category.cuisine_types.map(ct => `
        <li>
          <a href="#" data-action="mousedown->cuisine-type-select#select" data-id="${ct.id}" data-value="${ct.value}">
            ${ct.name}
          </a>
        </li>
      `).join('')}
    `).join('')
    
    this.resultsTarget.innerHTML = html
  }

  search() {
    const query = this.inputTarget.value.toLowerCase()
    
    if (query.length === 0) {
      // If query is empty, show all categories
      this.renderAllCategories()
      this.showResults()
      return
    }
    
    // Array to store matching cuisine types with their categories
    const matchingResults = []
    
    // Search through all categories and their cuisine types
    this.cuisineTypesValue.forEach(category => {
      const matchingCuisineTypes = category.cuisine_types.filter(ct => 
        ct.name.toLowerCase().includes(query)
      )
      
      if (matchingCuisineTypes.length > 0) {
        matchingResults.push({
          name: category.name,
          cuisine_types: matchingCuisineTypes
        })
      }
    })
    
    // Render the search results
    if (matchingResults.length > 0) {
      const html = matchingResults.map(category => `
        <li class="menu-title pt-0">${category.name}</li>
        ${category.cuisine_types.map(ct => `
          <li>
            <a href="#" data-action="mousedown->cuisine-type-select#select" data-id="${ct.id}" data-value="${ct.value}">
              ${ct.name}
            </a>
          </li>
        `).join('')}
      `).join('')
      
      this.resultsTarget.innerHTML = html
    } else {
      this.resultsTarget.innerHTML = '<li class="menu-title">No results found</li>'
    }
    
    this.showResults()
  }

  // Find cuisine type in the data structure based on id
  findCuisineType(id) {
    for (const category of this.cuisineTypesValue) {
      const foundCuisineType = category.cuisine_types.find(ct => ct.id === parseInt(id))
      if (foundCuisineType) {
        return foundCuisineType
      }
    }
    return null
  }

  select(event) {
    event.preventDefault()
    const id = event.currentTarget.dataset.id
    const value = event.currentTarget.dataset.value
    const cuisineType = this.findCuisineType(id)
    
    if (cuisineType) {
      this.hiddenInputTarget.value = value
      this.inputTarget.value = cuisineType.name
    }
    
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