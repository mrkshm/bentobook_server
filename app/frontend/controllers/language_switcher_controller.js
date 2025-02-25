import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['button', 'menu'];

  connect() {
    // Initialize localStorage based on current URL on initial page load
    // This ensures localStorage matches what the server has redirected to
    const isFrenchPath = window.location.pathname.startsWith('/fr');
    const currentLocale = isFrenchPath ? 'fr' : 'en';
    
    // Only set localStorage if it differs from the current path
    // This prevents fighting with the server's locale preference
    if (localStorage.getItem('locale') !== currentLocale) {
      localStorage.setItem('locale', currentLocale);
    }

    // Set up event listener for clicks outside the menu
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  toggleDropdown(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle('hidden');
    const isExpanded = this.buttonTarget.getAttribute('aria-expanded') === 'true';
    this.buttonTarget.setAttribute('aria-expanded', !isExpanded);
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden');
      this.buttonTarget.setAttribute('aria-expanded', 'false');
    }
  }

  switchLocale(event) {
    event.preventDefault();
    
    const newLocale = event.currentTarget.dataset.locale;
    localStorage.setItem('locale', newLocale);
    
    // Get the current path
    let currentPath = window.location.pathname;
    
    // If we're switching to French
    if (newLocale === 'fr') {
      // If path already starts with /fr, don't modify it
      if (currentPath.startsWith('/fr')) {
        this.menuTarget.classList.add('hidden'); // Just close the menu
        return; 
      }
      // Otherwise, add the French prefix
      window.location.pathname = `/fr${currentPath === '/' ? '' : currentPath}`;
    } 
    // If we're switching to English
    else {
      // If we're on a French path, remove the prefix
      if (currentPath.startsWith('/fr')) {
        const englishPath = currentPath.replace(/^\/fr/, '') || '/';
        window.location.pathname = englishPath;
      } else {
        this.menuTarget.classList.add('hidden'); // Just close the menu
      }
    }
  }
}
