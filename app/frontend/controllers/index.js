// Stimulus controllers auto-registration
console.log("🔧 Loading controllers/index.js...")
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Import all controller files and register them automatically
const controllerModules = import.meta.glob('./*_controller.js', { eager: true })

for (const path in controllerModules) {
  const module = controllerModules[path]
  const controllerName = path
    .replace('./', '')
    .replace('_controller.js', '')
    .replace(/_/g, '-')
  
  if (module.default) {
    application.register(controllerName, module.default)
    console.log(`✅ Registered controller: ${controllerName}`)
  }
}

console.log("🎯 All Stimulus controllers loaded via Vite!")

// Listen for Turbo frame loads to re-scan for controllers
document.addEventListener('turbo:frame-load', () => {
  console.log("🔄 Turbo frame loaded, Stimulus should auto-scan...")
})