import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selectedRecipients", "recipientIds"]
  static values = { profileSearchUrl: String }

  connect() {
    this.hideResults()
    this.selectedUsers = new Set()
  }

  async search() {
    const query = this.inputTarget.value

    if (query.length < 2) {
      this.hideResults()
      return
    }

    try {
      const baseUrl = this.profileSearchUrlValue || '/profiles/search'
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
    const profileId = button.dataset.profileId
    const profileName = button.dataset.profileName
    const avatarUrl = button.dataset.profileAvatarUrl

    if (this.selectedUsers.has(profileId)) {
      return
    }

    this.selectedUsers.add(profileId)

    const selectedUser = document.createElement('div')
    selectedUser.className = 'flex items-center justify-between p-3 bg-base-200 rounded-lg gap-4'
    selectedUser.innerHTML = `
      <div class="flex items-center gap-4">
        <div class="avatar">
          <div class="w-16 h-16 rounded-full">
            <img src="${avatarUrl}" alt="${profileName}" />
          </div>
        </div>
        <div class="font-medium text-lg">${profileName}</div>
      </div>
      <button type="button" 
              class="btn btn-ghost btn-circle" 
              data-profile-id="${profileId}"
              data-action="click->profile-search#removeRecipient">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `
    this.selectedRecipientsTarget.appendChild(selectedUser)

    // Add hidden input for form submission
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = 'recipient_ids[]'
    input.value = profileId
    this.recipientIdsTarget.appendChild(input)

    // Clear search input and results
    this.inputTarget.value = ''
    this.hideResults()
  }

  removeRecipient(event) {
    const button = event.currentTarget
    const profileId = button.dataset.profileId
    
    // Remove from selected set
    this.selectedUsers.delete(profileId)
    
    // Remove the entire card div (parent of the button)
    button.closest('.flex.items-center.justify-between').remove()
    
    // Remove hidden input
    this.recipientIdsTarget.querySelector(`input[value="${profileId}"]`).remove()
  }

  showResults() {
    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }
}