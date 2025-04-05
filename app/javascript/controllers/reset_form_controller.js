import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset-form"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("ResetFormController connected")

    // Add event listener for keydown events on input fields
    this.element.addEventListener('keydown', this.handleKeyDown.bind(this))
  }

  disconnect() {
    // Clean up event listener when controller disconnects
    this.element.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }

  handleKeyDown(event) {
    // Check if the Enter key was pressed and not with the Shift key
    if (event.key === 'Enter' && !event.shiftKey) {
      // Prevent default behavior (which would add a newline in textarea)
      event.preventDefault()

      // Submit the form
      this.element.requestSubmit()
    }
  }

  reset() {
    console.log("Resetting form")
    this.element.reset()

    // Optional: focus the input field after reset
    const inputField = this.element.querySelector('input, textarea')
    if (inputField) {
      inputField.focus()
    }
  }
}
