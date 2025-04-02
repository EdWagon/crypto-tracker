import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-search"
export default class extends Controller {
  static targets = ["searchField1", "list1", "searchField2", "list2"]

  search1() {
    const query = this.searchField1Target.value;

    if (query.length > 1) {
      fetch(`/search-coins?query=${encodeURIComponent(query)}`, { headers: { "Accept" : "application/json" }})
        .then(response => response.json())
        .then(data => {
          this.list1Target.innerHTML = ""; // Clear previous results
          if (data.length > 0) {
            data.forEach((coin) => {
              const option = document.createElement("option");
              option.value = coin.name; // Set the value of the option
              option.textContent = `${coin.name} (${coin.symbol})`; // Set the display text
              this.list1Target.appendChild(option);
            })
          } else {
            this.list1Target.innerHTML = "<option>No results found.</option>";
          }
        });
    }
  }
  search2() {
    const query = this.searchField2Target.value;

    if (query.length > 1) {
      fetch(`/search-coins?query=${encodeURIComponent(query)}`, { headers: { "Accept" : "application/json" }})
        .then(response => response.json())
        .then(data => {

          this.list2Target.innerHTML = ""; // Clear previous results

          if (data.length > 0) {
            data.forEach((coin) => {
              const option = document.createElement("option");
              option.value = coin.name; // Set the value of the option
              option.textContent = `${coin.name} (${coin.symbol})`; // Set the display text
              this.list2Target.appendChild(option);
            })
          } else {
            this.list2Target.innerHTML = "<option>No results found.</option>";
          }
        });
    }
  }
}
