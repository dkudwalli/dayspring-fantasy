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

    if (this.hasSubmitTarget) this.submitTarget.disabled = !complete
    if (!this.hasMessageTarget) return

    this.messageTarget.textContent = complete ?
      "All questions answered. You can save or update your picks." :
      "Select one option for every question to enable saving."

    this.updateMessageState(complete ? "complete" : "incomplete")
  }

  requiredGroups() {
    const names = Array.from(this.element.querySelectorAll("input[type='radio'][required]"))
      .map((input) => input.name)

    return [...new Set(names)]
  }

  updateMessageState(state) {
    const stateClasses = {
      complete: ["border-emerald-200", "bg-emerald-50", "text-emerald-800"],
      incomplete: ["border-amber-200", "bg-amber-50", "text-amber-900"]
    }
    const allClasses = Object.values(stateClasses).flat()

    this.messageTarget.classList.remove(...allClasses)
    this.messageTarget.classList.add(...stateClasses[state])
  }
}
