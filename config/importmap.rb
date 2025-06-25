# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/scripts", under: "scripts"

# Pin lightbox component
pin "@stimulus-components/lightbox", to: "https://ga.jspm.io/npm:@stimulus-components/lightbox@3.1.0/dist/stimulus-lightbox.mjs"
pin "@hotwired/hotwire-native-bridge", to: "@hotwired--hotwire-native-bridge.js" # @1.2.1
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.13
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.16
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.0.200
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.200
