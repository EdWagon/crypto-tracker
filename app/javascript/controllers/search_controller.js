import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search(event) {
    console.log("seachjavascript")
    event.preventDefault()
    // this.resultsTarget.innerHTML = ""

    let query = this.inputTarget.value.trim()
    if (query.length > 1) {
      fetch(`/search?query=${query}`, { headers: { "Accept" : "application/json" }})
        .then(response => response.json())
        .then((data) => {
          console.log(data)
          if (data.length > 0) {
            data.forEach((result) => {
              const searchTag = `<li class="list-group-item">
                <strong>${result.searchable_type}:</strong>
                <a href="${result.searchable_path}" class="fw-bold text-decoration-none">${result.searchable_name}</a>
              </li>`
              this.resultsTarget.insertAdjacentHTML("beforeend", searchTag)
            })
          } else {
            this.resultsTarget.innerHTML = "<li class='list-group-item text-muted'>No results found.</li>"
          }
        })
    }
  }
}
