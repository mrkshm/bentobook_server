import '../stylesheets/application.css';

import { initializeNavbar } from '../scripts/navbar';
import '../scripts/page_render';
import "lightgallery/css/lightgallery.css"

import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import Lightbox from '@stimulus-components/lightbox'
import { registerControllers } from "stimulus-vite-helpers"

// Configure Turbo
document.addEventListener("turbo:before-cache", () => {
  // Clear any dynamic content that shouldn't be cached
})

document.addEventListener("turbo:load", () => {
  initializeNavbar();
})

document.addEventListener("turbo:visit", () => {
  // Clear any state before navigating
})

// Prevent Turbo from caching pages
Turbo.setProgressBarDelay(100)
Turbo.setConfirmMethod((message) => Promise.resolve(confirm(message)))

// Initialize Stimulus application
const application = Application.start();
application.register('lightbox', Lightbox, {
  plugins: [],
  speed: 500,
})

// Register all Stimulus controllers
const controllers = import.meta.glob("../controllers/**/*_controller.js", { eager: true })
registerControllers(application, controllers)

// Make available for Stimulus debugging in browser console
window.Stimulus = application

// Start Turbo
Turbo.start();

// Event listeners
document.addEventListener('turbo:render', initializeNavbar);

// Fallback for non-Turbo pages
document.addEventListener('DOMContentLoaded', () => {
  if (typeof Turbo === 'undefined') {
    initializeThemeSwitcher();
    initializeNavbar();
  }
});

console.log('🔥 ALPINE INITIALIZED 🔥');
console.log('Vite ⚡️ Rails');

// Example: Load Rails libraries in Vite.
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
