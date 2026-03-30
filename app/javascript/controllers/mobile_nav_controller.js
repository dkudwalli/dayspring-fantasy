import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button", "openIcon", "closeIcon"]

  connect() {
    this.open = false
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
    this.sync()
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  toggle() {
    this.open = !this.open
    this.sync()
  }

  close() {
    if (!this.open) return

    this.open = false
    this.sync()
  }

  handleResize() {
    if (window.innerWidth >= 1024 && this.open) {
      this.open = false
      this.sync()
    }
  }

  sync() {
    if (this.hasPanelTarget) {
      this.panelTargets.forEach((panel) => {
        panel.classList.toggle("hidden", !this.open)
      })
    }

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", String(this.open))
    }

    if (this.hasOpenIconTarget) {
      this.openIconTarget.classList.toggle("hidden", this.open)
    }

    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.toggle("hidden", !this.open)
    }
  }
}
