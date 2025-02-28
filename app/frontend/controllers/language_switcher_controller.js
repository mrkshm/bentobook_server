import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['button', 'menu'];

  connect() {
    console.log("Language switcher controller connected"); // Debug connection
    
    // Initialize localStorage based on current URL on initial page load
    const isFrenchPath = window.location.pathname.startsWith('/fr');
    const currentLocale = isFrenchPath ? 'fr' : 'en';
    
    if (localStorage.getItem('locale') !== currentLocale) {
      localStorage.setItem('locale', currentLocale);
    }

    // Set up event listener for clicks outside the menu
    this.clickOutsideHandler = this.handleClickOutside.bind(this);
    document.addEventListener('click', this.clickOutsideHandler);
  }

  disconnect() {
    // Properly remove event listener using the same function reference
    document.removeEventListener('click', this.clickOutsideHandler);
  }

  toggleDropdown(event) {
    event.preventDefault();
    event.stopPropagation();
    console.log("Toggle dropdown clicked"); // Debug click
    
    this.menuTarget.classList.toggle('hidden');
    const isExpanded = this.buttonTarget.getAttribute('aria-expanded') === 'true';
    this.buttonTarget.setAttribute('aria-expanded', !isExpanded);
  }

  handleClickOutside(event) {
    if (this.element.contains(event.target)) {
      return; // Click was inside component, do nothing
    }
    
    // Click was outside component, close dropdown
    this.menuTarget.classList.add('hidden');
    this.buttonTarget.setAttribute('aria-expanded', 'false');
  }

  switchLocale(event) {
    event.preventDefault();
    console.log("Switching locale"); // Debug locale switch
    
    const newLocale = event.currentTarget.dataset.locale;
    localStorage.setItem('locale', newLocale);
    
    // Get the current path without query parameters
    let currentPath = window.location.pathname;
    const queryString = window.location.search || '';
    
    // If we're switching to French
    if (newLocale === 'fr') {
      // If path already starts with /fr, don't modify it
      if (currentPath.startsWith('/fr')) {
        this.menuTarget.classList.add('hidden'); // Just close the menu
        return; 
      }
      // Otherwise, add the French prefix
      const newPath = `/fr${currentPath === '/' ? '' : currentPath}${queryString}`;
      window.location.href = newPath;
    } 
    // If we're switching to English
    else {
      // If we're on a French path, remove the prefix
      if (currentPath.startsWith('/fr')) {
        const englishPath = currentPath.replace(/^\/fr/, '') || '/';
        window.location.href = `${englishPath}${queryString}`;
      } else {
        this.menuTarget.classList.add('hidden'); // Just close the menu
      }
    }
  }
}
