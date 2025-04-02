import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "typeField",
    "coinInField",
    "coinOutField",
    "receivingWalletField",
    "sendingWalletField",
    "orderValueField",
    "quantityInField",
    "quantityOutField"
  ]

  connect() {
    this.updateFields() // Initialize form on load
  }

  updateFields() {
    const transactionType = this.typeFieldTarget.value

    // Hide all fields initially
    this.hideAllFields()

    // Show fields based on transaction type
    switch (transactionType) {
      case "buy":
        this.showFields([
          "coinInField",
          "receivingWalletField",
          "orderValueField",
          "quantityInField"
        ])
        break

      case "sell":
        this.showFields([
          "coinInField",
          "sendingWalletField",
          "orderValueField",
          "quantityInField"
        ])
        break

      case "deposit":
        this.showFields([
          "coinInField",
          "receivingWalletField",
          "orderValueField",
          "quantityInField"
        ])
        break

      case "withdrawal":
        this.showFields([
          "coinInField",
          "sendingWalletField",
          "orderValueField",
          "quantityInField"
        ])
        break

      case "swap":
        this.showFields([
          "coinInField",
          "coinOutField",
          "receivingWalletField",
          "sendingWalletField",
          "quantityInField",
          "quantityOutField",
          "orderValueField"
        ])
        break

      case "transfer":
        this.showFields([
          "coinInField",
          "receivingWalletField",
          "sendingWalletField",
          "quantityInField",
          "quantityOutField",
        ])
        break
    }

    // Update labels based on transaction type
    this.updateLabels(transactionType)
  }

  hideAllFields() {
    this.coinInFieldTarget.classList.add("d-none")
    this.coinOutFieldTarget.classList.add("d-none")
    this.receivingWalletFieldTarget.classList.add("d-none")
    this.sendingWalletFieldTarget.classList.add("d-none")
    this.orderValueFieldTarget.classList.add("d-none")
    this.quantityInFieldTarget.classList.add("d-none")
    this.quantityOutFieldTarget.classList.add("d-none")
  }

  showFields(fieldTargets) {
    fieldTargets.forEach(targetName => {
      this[targetName + "Target"].classList.remove("d-none")
    })
  }

  updateLabels(transactionType) {
    // You can customize labels based on transaction type if needed
    const labelMappings = {
      buy: {
        quantityIn: "Quantity Purchased",
        coinIn: "Coin Purchased"
      },
      sell: {
        quantityIn: "Quantity Sold",
        coinIn: "Coin Sold"
      },
      deposit: {
        quantityIn: "Quantity Deposited",
        coinIn: "Coin Deposited"
      },
      withdrawal: {
        quantityIn: "Quantity Withdrawn",
        coinIn: "Coin Withdrawn"
      },
      swap: {
        quantityIn: "Quantity Purchased",
        quantityOut: "Quantity Sold",
        coinIn: "Coin Purchased",
        coinOut: "Coin Sold"
      },
      transfer: {
        coinIn: "Coin Transfer",
        quantityIn: "Quantity Received",
        quantityOut: "Quantity Sent"
      }
    }

    // Update the labels if needed
    if (labelMappings[transactionType]) {
      const mapping = labelMappings[transactionType]

      if (mapping.quantityIn) {
        this.quantityInFieldTarget.querySelector("label").textContent = mapping.quantityIn
      }

      if (mapping.quantityOut) {
        this.quantityOutFieldTarget.querySelector("label").textContent = mapping.quantityOut
      }

      if (mapping.coinIn) {
        this.coinInFieldTarget.querySelector("label").textContent = mapping.coinIn
      }

      if (mapping.coinOut) {
        this.coinOutFieldTarget.querySelector("label").textContent = mapping.coinOut
      }
    }
  }
}
