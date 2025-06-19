import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.title = this.element.dataset.title
    this.min = parseInt(this.element.dataset.min)
    this.series = JSON.parse(this.element.dataset.series)
    this.formatter = this.element.dataset.formatter
  }

  connect() {
    const chart = new ApexCharts(this.element, {
      chart: {
        id: this.title,
        group: "metrics",
        height: "200px",
        type: "area",
        toolbar: {
          tools: {
            download: false
          }
        }
      },
      colors: ["#3b82f6", "#4ade80", "#facc15", "#dc2626", "#7c3aed"],
      dataLabels: {
        enabled: false
      },
      onDatasetHover: {
        highlightDataSeries: true,
      },
      series: this.series,
      stroke: {
        width: 1
      },
      title: {
        text: this.title
      },
      tooltip: {
        shared: true,
        x: {
          format: "dd/MM/yyyy HH:mm:ss"
        },
        y: {
          formatter: this.formatterFunction()
        }
      },
      xaxis: {
        type: "datetime",
        min: this.min
      },
      yaxis: {
        labels: { show: false }
      }
    })

    chart.render()
  }

  formatterFunction() {
    let f = function(value) {
      return value
    }

    if (this.formatter === "percentage") {
      f = function(value) {
        return `${value || 0}%`
      }
    }

    if (this.formatter === "size") {
      f = function(value) {
        return byteSize(value)
      }
    }

    if (this.formatter === "ms") {
      f = function(value) {
        return `${value.toFixed(2)} ms`
      }
    }

    return f
  }
}
