import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button', 'menu']

  connect() {
    // Handle clicking outside to close dropdown
    document.addEventListener('click', this.handleClickOutside.bind(this));
    
    // On page load, check if we should redirect based on localStorage
    const storedLocale = localStorage.getItem('locale');
    const currentPath = window.location.pathname;
    const isFrenchPath = currentPath.startsWith('/fr');

    if (storedLocale) {
      const shouldBeFrench = storedLocale === 'fr';
      if (shouldBeFrench !== isFrenchPath) {
        window.location = shouldBeFrench ? '/fr' : '/';
      }
    } else {
      // Initialize localStorage based on current path
      localStorage.setItem('locale', isFrenchPath ? 'fr' : 'en');
    }
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
    const newLocale = event.currentTarget.dataset.locale;
    localStorage.setItem('locale', newLocale);
  }
}
