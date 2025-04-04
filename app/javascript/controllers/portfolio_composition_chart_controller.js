import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

export default class extends Controller {
  connect() {
    console.log("polar-area-chart Controller Connected ");
    this.resizeObserver = new ResizeObserver(entries => this.handleResize());
    this.resizeObserver.observe(this.element);
    this.load();
  }

  disconnect() {
    // Clean up the ResizeObserver when the controller disconnects
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }

    // Destroy the chart to prevent memory leaks
    if (this.chart) {
      this.chart.destroy();
    }
  }

  handleResize() {
    if (this.chart) {
      this.chart.resize();
    }
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
          '#9666D9',
          '#F2B6A0',
          '#297373',
          '#FF4500',
          '#F20574',
          '#3F6CA6',
          '#F7921B'
        ]
      }]
    };

    const polarChart = new Chart(this.element, {
      type: 'pie',
      data,
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    });
  }
}
