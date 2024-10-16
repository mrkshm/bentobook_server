import '../stylesheets/application.css'
import { initializeThemeSwitcher } from '../scripts/theme_switcher'
import { initializeNavbar } from '../scripts/navbar'
// app/frontend/entrypoints/application.js

// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

import { Application } from "@hotwired/stimulus"
import { registerControllers } from 'stimulus-vite-helpers'

// Import all controllers
import controllers from '../controllers/**/*_controller.js'

// Initialize Stimulus application
const application = Application.start()

// Register all controllers
registerControllers(application, controllers)

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
import * as Turbo from '@hotwired/turbo'
Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
