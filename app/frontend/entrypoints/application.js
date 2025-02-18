import '../stylesheets/application.css';
import Alpine from 'alpinejs';

window.Alpine = Alpine;
Alpine.start();

import { initializeThemeSwitcher } from '../scripts/theme_switcher';
import { initializeNavbar } from '../scripts/navbar';
import '../scripts/page_render';

import { Application } from '@hotwired/stimulus';
import { registerControllers } from 'stimulus-vite-helpers';
import '@hotwired/turbo-rails';
console.log('🔥 ALPINE INITIALIZED 🔥');
console.log('Vite ⚡️ Rails');

// Initialize Stimulus application
const application = Application.start();

// Register all controllers in the controllers directory
const controllers = import.meta.glob('../controllers/**/*_controller.js', {
  eager: true,
});
registerControllers(application, controllers);

// Turbo
import * as Turbo from '@hotwired/turbo';
Turbo.start();

// Event listeners
document.addEventListener('turbo:load', () => {
  initializeThemeSwitcher();
  initializeNavbar();
});

document.addEventListener('turbo:render', initializeNavbar);

// Fallback for non-Turbo pages
document.addEventListener('DOMContentLoaded', () => {
  if (typeof Turbo === 'undefined') {
    initializeThemeSwitcher();
    initializeNavbar();
  }
});

// Example: Load Rails libraries in Vite.
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
