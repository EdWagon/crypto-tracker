import { Controller } from "@hotwired/stimulus";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

export default class extends Controller {
  static targets = ['chart', 'container', 'oneDayBtn', 'oneWeekBtn', 'oneMonthBtn', 'oneYearBtn'];
  static values = {
    coinid: {type: String},
    range: { type: String }
  };

  connect() {
    console.log("line-chart Controller Connected");
    this.highlightActiveButton();
    this.loadChart();
    window.addEventListener('resize', this.handleResize.bind(this));
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize.bind(this));
    if (this.chart) {
      this.chart.destroy();
    }
  }


  // Range value change observer
  rangeValueChanged() {
    this.highlightActiveButton();
  }


  // Highlight the active button based on current range
  highlightActiveButton() {
    // Get all the button targets
    const buttonTargets = [
      'oneDayBtnTarget',
      'oneWeekBtnTarget',
      'oneMonthBtnTarget',
      'oneYearBtnTarget'
    ];

    // Remove active class from all buttons
    buttonTargets.forEach(targetName => {
      if (this[targetName]) {
        this[targetName].classList.remove('active');
      }
    });

    // Add active class to the current range button
    const rangeToTargetMap = {
      '1d': 'oneDayBtnTarget',
      '1w': 'oneWeekBtnTarget',
      '1m': 'oneMonthBtnTarget',
      '1y': 'oneYearBtnTarget'
    };

    const targetName = rangeToTargetMap[this.rangeValue];
    if (targetName && this[targetName]) {
      this[targetName].classList.add('active');
    }
  }

  setRange(event) {
    event.preventDefault();
    const range = event.currentTarget.dataset.range;
    this.rangeValue = range;
    this.loadChart();
  }


  loadChart() {
    const url = `/coins/${this.coinidValue}/prices.json?range=${this.rangeValue}`;
    console.log("Fetching price data from:", url);

    fetch(url, {
      method: "GET",
      headers: {"Accept": "application/json"}
    })
    .then(response => response.json())
    .then(data => {
      console.log("Received price data:", data);
      this.renderChart(data);
    })
    .catch(error => {
      console.error("Error fetching price data:", error);
    });
  }

  getContainerSize() {
    if (this.hasContainerTarget) {
      const containerRect = this.containerTarget.getBoundingClientRect();
      console.log("Container width:", containerRect.width);
      console.log("Container height:", containerRect.height);

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
    const prices = priceData.map(item => item.price);

    const data = {
      labels: dates,
      datasets: [{
        label: "AUD",
        legend: false,
        data: prices,
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
            reverse: true,
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

  load() {

      // const url = `/coins/${this.coinIdValue}/prices.json?range=${this.rangeValue}`;
      url= "http://localhost:3000/coins/1/prices?range=1y"
      fetch(url, {
        method: "GET",
        headers: {"Accept": "application/json"}
      })
      .then(response => response.json())
      .then(data => {
        console.log("Received price data:", data);
        this.renderChart(data);
      })
      .catch(error => {
        console.error("Error fetching price data:", error);
      });



    const labelValues = Object.keys(dataTimeSeries);
    const dataValues = Object.values(dataTimeSeries);

    const data = {
      labels: labelValues,
      datasets: [{
        label: "Coin Price",
        data: dataValues,
        fill: true,
        // parsing: false,
        borderColor: 'rgb(75,192,192)',
        pointHoverBackgroundColor: 'rgb(75,192,192)',

        tension: 0.1
      }]
    };



    const lineChart = new Chart(this.chartTarget, {
      type: 'line',
      data,
      plugins: [verticalHoverLine]
    });
  }




}
