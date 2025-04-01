import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-search"
export default class extends Controller {
  static targets = ["searchField", "list"]

  connect() {
    console.log(this.listTarget);
  }

  search() {
    const query = this.searchFieldTarget.value;

    if (query.length > 1) {
      fetch(`/search-coins?query=${encodeURIComponent(query)}`, { headers: { "Accept" : "application/json" }})
        .then(response => response.json())
        .then(data => {
          this.listTarget.innerHTML = ""; // Clear previous results
          if (data.length > 0) {
            data.forEach((coin) => {
              const option = document.createElement("option");
              option.value = coin.name; // Set the value of the option
              option.textContent = `${coin.name} (${coin.symbol})`; // Set the display text
              this.listTarget.appendChild(option);
            })
          } else {
            this.listTarget.innerHTML = "<option>No results found.</option>";
          }
        });
    }
  }
}
