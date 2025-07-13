// Vite + Bun entrypoint
console.log("🚀 Starting Vite application.js...")

import "@hotwired/turbo-rails"
console.log("✅ Turbo Rails loaded")

import "~/controllers"
console.log("✅ Controllers import attempted")

// Turbo stream actions
Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("location"))
}

Turbo.StreamActions.close_frame_dialog = function() {
  this.targetElements.forEach((e) => e.closest("dialog").close())
}

console.log("🚀 Vite + Bun application loaded!")