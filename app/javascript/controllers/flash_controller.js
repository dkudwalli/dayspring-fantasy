import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    const timeout = this.timeoutValue || 0
    if (timeout <= 0) return

    this.timeout = window.setTimeout(() => this.dismiss(), timeout)
  }

  disconnect() {
    if (this.timeout) window.clearTimeout(this.timeout)
  }

  dismiss() {
    if (this.timeout) window.clearTimeout(this.timeout)
    this.element.remove()
  }
}
