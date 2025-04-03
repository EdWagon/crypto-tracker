import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    console.log("polar-area-chart Controller Connected ");
    this.load();
  }

  load() {

    const url = `portfolio/composition.json`;
    console.log("Fetching price data from:", url);

    fetch(url, {
      method: "GET",
      headers: {"Accept": "application/json"}
    })
    .then(response => response.json())
    .then(data => {
      // console.log("Received price data:", data);
      this.renderChart(data);
    })
    .catch(error => {
      console.error("Error fetching price data:", error);
    });

  }
  renderChart(compositionData) {
    if (this.chart) {
      this.chart.destroy();
    }

    if (!compositionData || compositionData.length === 0) {
      console.warn("No composition data available to render chart");
      return;
    }

    const coin = compositionData.map(item => item.coin);
    const values = compositionData.map(item => item.total_value);

    // const worldPopulationGrowth = {
    //   Christianity: 2380000000,
    //   Islam: 1910000000,
    //   Hinduism: 1100000000,
    //   Irreligion: 1100000000,
    //   Buddhism: 500000000,
    //   "Folk Religions": 400000000,
    //   Sikhism: 25000000,
    //   Judaism: 14000000,
    //   "Bahai Faith": 7000000,
    //   Jainism: 4500000,
    //   // your turn now to fill the rest of the object until 2010
    // };
    // const labelValues = Object.keys(worldPopulationGrowth);
    // const dataValues = Object.values(worldPopulationGrowth);

    const data = {
      labels: coin,
      datasets: [{
        label: "Portfolio Composition",
        data: values,
        fill: true,
        borderWidth: 0,
        // hoverOffset: 10,
        backgroundColor: [
          '#2b3ff2',
          '#8EF27E',
          'rgb(255, 99, 132)',
          'rgb(75, 192, 192)',
          'rgb(255, 205, 86)',
          'rgb(201, 203, 207)',
          'rgb(54, 162, 235)',
          'rgb(255, 99, 132)',
          'rgb(75, 192, 192)',
          'rgb(255, 205, 86)',
          'rgb(201, 203, 207)',
          'rgb(54, 162, 235)'],
      }]
    };

    const polarChart = new Chart(this.element, {
      type: 'pie',
      data,
      options: {}
    });
  }
}
