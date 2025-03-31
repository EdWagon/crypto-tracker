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
                  <strong>Coin:</strong> <a class="fw-bold text-decoration-none" href="/coins/${coin.id}">${coin.name} - ${coin.symbol}</a>
                </li>`
                this.resultsTarget.insertAdjacentHTML("beforeend", searchTag)
              })
            }
            if (data.wallets.length > 0) {
              this.resultsTarget.style.display = "block"
              data.wallets.forEach((wallet) => {
                console.log(wallet);

                const searchTag = `<li class="list-group-item">
                  <strong>Wallet:</strong> <a class= "fw-bold text-decoration-none" href="/wallets/${wallet.id}">${wallet.name} - ${wallet.wallet_type} - ${wallet.wallet_address}</a>
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
