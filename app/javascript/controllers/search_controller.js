import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search(event) {
    event.preventDefault()
    this.resultsTarget.innerHTML = ""

    let query = this.inputTarget.value.trim()
    if (query.length > 1) {
      fetch(`/search?query=${query}`, { headers: { "Accept" : "application/json" }})
        .then(response => response.json())
        .then((data) => {
          if (data.coins.length > 0 || data.wallets.length > 0) {
            if (data.coins.length > 0) {
              this.resultsTarget.style.display = "block"
              data.coins.forEach((coin) => {
                console.log(coin);

                const searchTag = `<li class="list-group-item">
                  <strong>${coin.symbol}:</strong>
                  <a href="/coins/${coin.id}" class="fw-bold text-decoration-none">${coin.name}</a>
                </li>`
                this.resultsTarget.insertAdjacentHTML("beforeend", searchTag)
              })
            }
            if (data.wallets.length > 0) {
              this.resultsTarget.style.display = "block"
              data.wallets.forEach((wallet) => {
                console.log(wallet);

                const searchTag = `<li class="list-group-item">
                  <strong>${wallet.symbol}:</strong>
                  <a href="/wallets/${wallet.id}" class="fw-bold text-decoration-none">${wallet.name}</a>
                </li>`
                this.resultsTarget.insertAdjacentHTML("beforeend", searchTag)
              })
            }
          } else {
            this.resultsTarget.innerHTML = "<li class='list-group-item text-muted'>No results found.</li>"
          }
        })
    }
  }

}
