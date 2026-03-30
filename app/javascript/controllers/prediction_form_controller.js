import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "message"]
  static values = { locked: Boolean }

  connect() {
    this.refresh()
  }

  refresh() {
    if (this.lockedValue) return

    const complete = this.requiredGroups().every((name) => {
      return this.element.querySelector(`input[type="radio"][name="${name}"]:checked`)
    })

    this.submitTarget.disabled = !complete
    this.messageTarget.textContent = complete ?
      "All questions answered. You can save or update your picks." :
      "Select one option for every question to enable saving."
    this.messageTarget.classList.toggle("form-note", complete)
    this.messageTarget.classList.toggle("form-alert", !complete)
  }

  requiredGroups() {
    const names = Array.from(this.element.querySelectorAll("input[type='radio'][required]"))
      .map((input) => input.name)

    return [...new Set(names)]
  }
}
