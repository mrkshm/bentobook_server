import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selectedOrganizations", "organizationIds"]
  static values = { url: String }

  connect() {
    this.hideResults()
    this.selectedOrgs = new Set()
  }

  async search() {
    const query = this.inputTarget.value

    if (query.length < 2) {
      this.hideResults()
      return
    }

    try {
      const baseUrl = this.urlValue || '/organizations/search'
      const url = `${baseUrl}?query=${encodeURIComponent(query)}`

      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
          'Turbo': 'false'
        }
      })
      
      if (!response.ok) throw new Error('Network response was not ok')
      
      const html = await response.text()
      this.resultsTarget.innerHTML = html
      this.showResults()
    } catch (error) {
      console.error('Search error:', error)
    }
  }

  select(event) {
    const button = event.currentTarget
    const organizationId = button.dataset.organizationId
    const organizationName = button.dataset.organizationName
    const avatarUrl = button.dataset.organizationAvatarUrl

    if (this.selectedOrgs.has(organizationId)) {
      return
    }

    this.selectedOrgs.add(organizationId)

    const selectedOrganization = document.createElement('div')
    selectedOrganization.className = 'flex items-center justify-between p-3 bg-base-200 rounded-lg gap-4'
    selectedOrganization.innerHTML = `
      <div class="flex items-center gap-4">
        <div class="avatar">
          <div class="w-16 h-16 rounded-full">
            <img src="${avatarUrl}" alt="${organizationName}" />
          </div>
        </div>
        <div class="font-medium text-lg">${organizationName}</div>
      </div>
      <button type="button" 
              class="btn btn-ghost btn-circle" 
              data-organization-id="${organizationId}"
              data-action="click->organization-search#removeOrganization">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `
    this.selectedOrganizationsTarget.appendChild(selectedOrganization)

    // Add hidden input for form submission
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = 'target_organization_ids[]'
    input.value = organizationId
    this.organizationIdsTarget.appendChild(input)

    // Clear search input and results
    this.inputTarget.value = ''
    this.hideResults()
  }

  removeOrganization(event) {
    const button = event.currentTarget
    const organizationId = button.dataset.organizationId
    
    // Remove from selected set
    this.selectedOrgs.delete(organizationId)
    
    // Remove the entire card div (parent of the button)
    button.closest('.flex.items-center.justify-between').remove()
    
    // Remove hidden input
    this.organizationIdsTarget.querySelector(`input[value="${organizationId}"]`).remove()
  }

  showResults() {
    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }
}
