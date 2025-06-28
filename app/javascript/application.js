// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("location"))
}

Turbo.StreamActions.close_frame_dialog = function() {
  this.targetElements.forEach((e) => e.closest("dialog").close())
}