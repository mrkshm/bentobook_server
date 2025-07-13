import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.showModal()

        this.element.addEventListener("close", () => {
            this.element.remove()
        })

        this.element.addEventListener("click", this.outsideClickListener)
    }

    disconnect() {
        this.element.removeEventListener("click", this.outsideClickListener)
    }

    outsideClickListener = (event) => {
        if (event.target === this.element) {
            this.element.close()
        }
    }
}
