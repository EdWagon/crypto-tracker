import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

export default class extends Controller {
  static targets = ['chart', 'container', 'oneDayBtn', 'oneWeekBtn', 'oneMonthBtn', 'oneYearBtn'];
  static values = {
    userid: {type: String},
    range: { type: String }
  };

  connect() {
    console.log("Performance Chart Controller Connected");
    // this.highlightActiveButton();
    this.loadChart();
    window.addEventListener('resize', this.handleResize.bind(this));
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize.bind(this));
    if (this.chart) {
      this.chart.destroy();
    }
  }


  loadChart() {
    const url = `portfolio/timeseries.json?range=${this.rangeValue}`;
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

  getContainerSize() {
    if (this.hasContainerTarget) {
      const containerRect = this.containerTarget.getBoundingClientRect();
      // console.log("Container width:", containerRect.width);
      // console.log("Container height:", containerRect.height);

      // You can store these values if needed
      this.containerWidth = containerRect.width;
      this.containerHeight = containerRect.height;

      return { width: containerRect.width, height: containerRect.height };
    }
    return null;
  }

  handleResize() {
    // Update container size on window resize
    this.getContainerSize();

    // Update chart dimensions if needed
    if (this.chart) {
      this.chart.resize();
    }
  }

  resize() {
    console.log("resize triggered");
    if (this.chart) {
      this.chart.resize();
      console.log("Chart resized");
    }
  }


  renderChart(priceData) {
    // Destroy existing chart if it exists
    if (this.chart) {
      this.chart.destroy();
    }

    if (!priceData || priceData.length === 0) {
      console.warn("No price data available to render chart");
      return;
    }

    // Extract dates and prices from the data
    const dates = priceData.map(item => new Date(item.date).toLocaleDateString());
    const value = priceData.map(item => item.total_value);
    const invested = priceData.map(item => item.total_invested);


    const data = {
      labels: dates,
      datasets: [
      {
        label: "Value",
        legend: false,
        data: value,
        fill: false,
        borderColor: '#2b3ff2',
        pointHoverRadius: 5,
        pointHoverBackgroundColor: 'rgb(175, 83, 255)',
        tension: 0.1
      },
      {
        label: "Invested",
        legend: false,
        data: invested,
        fill: false,
        borderColor: '#8EF27E',
        pointHoverRadius: 5,
        pointHoverBackgroundColor: 'rgb(175, 83, 255)',
        tension: 0.1
      }]
    };

    const verticalHoverLine = {
      id: 'verticalHoverLine',
      beforeDatasetsDraw(chart, args, plugins) {
        const { ctx, chartArea: { top, bottom, height } } = chart;
        ctx.save();
        chart.getDatasetMeta(0).data.forEach((dataPoint, index) => {
          if (dataPoint.active === true){
            ctx.beginPath();
            ctx.strokeStyle = 'rgba(173, 173, 173, 0.5)';
            ctx.lineWidth = 1;
            ctx.moveTo(dataPoint.x, top);
            ctx.lineTo(dataPoint.x, bottom);
            ctx.stroke();
          }
        })
        ctx.restore();
      }
    };

    const config = {
      type: 'line',
      data: data,
      options: {
        pointRadius: 0,
        // pointHoverRadius: 5,
        // hoverBackgroundColor: 'rgb(75, 192, 192)',
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: 'index',
          intersect: false,
        },
        plugins: {
          legend: {
            display: false  // This will hide the legend
          }
        },
        scales: {
          x: {
            border: {
              display: true
            },
            reverse: false,
            grid: {
              color: '#313131',
            },
            title: {
              display: false,
              text: 'Date'
            },
            ticks: {
              autoSkip: true,
              maxTicksLimit: 12
            }
          },
          y: {
            border: {
              display: true
            },
            grid: {
              color: '#313131',
            },
            title: {
              display: false,
              text: 'AUD'
            }
          }
        }
      },
      plugins: [verticalHoverLine]
    };

    // Create new chart and save reference
    this.chart = new Chart(this.chartTarget, config);
  }

}
