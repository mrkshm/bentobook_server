import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
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

  // Called before following the link
  storeLocale(event) {
    const newLocale = event.currentTarget.dataset.locale;
    localStorage.setItem('locale', newLocale);
  }
}
