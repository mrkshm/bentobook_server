import { Controller } from "@hotwired/stimulus"

function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

export default class extends Controller {
  static targets = ["input", "frequent", "suggestedContacts"]
  
  connect() {
    console.log("ContactSearchController connected")
    this.performSearch = debounce(this.performSearch.bind(this), 300)
    this.toggleSuggestedContacts()
  }

  performSearch() {
    const query = this.inputTarget.value
    console.log("Performing search with query:", query)
    this.toggleSuggestedContacts()
    if (query.length === 0) {
      // Clear results when search is empty
      const frame = document.getElementById("search-results")
      frame.innerHTML = ""
    } else if (query.length >= 2) {
      this.inputTarget.form.requestSubmit()
    }
  }

  toggleSuggestedContacts() {
    if (this.hasSuggestedContactsTarget) {
      if (this.inputTarget.value.length > 0) {
        this.suggestedContactsTarget.classList.add("hidden")
      } else {
        this.suggestedContactsTarget.classList.remove("hidden")
      }
    }
  }
}