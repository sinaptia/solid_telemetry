import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    this.title = this.element.dataset.title
    this.min = parseInt(this.element.dataset.min)
    this.series = JSON.parse(this.element.dataset.series)
    this.plotLines = this.element.dataset.annotations ? JSON.parse(this.element.dataset.annotations) : []
    this.formatter = this.element.dataset.formatter
  }

  connect() {
    Highcharts.chart(this.element, {
      chart: {
        height: "200px",
        type: "area",
        zooming: { type: "x" },
        events: {
          selection: this.resetZoom()
        }
      },
      title: {
        text: this.title,
        align: "left",
        x: 30
      },
      credits: { enabled: false },
      xAxis: {
        type: "datetime",
        crosshair: true,
        min: this.min,
        events: {
          setExtremes: this.syncExtremes()
        }
      },
      yAxis: {
        title: { text: null },
        labels: { enabled: false },
        allowDecimals: true,
        plotLines: this.plotLines
      },
      tooltip: {
        shared: true,
        pointFormatter: this.formatterFunction()
      },
      plotOptions: {
        area: {
          marker: {
            enabled: false,
            symbol: "circle",
            radius: 2,
            states: {
              hover: { enabled: true }
            }
          }
        }
      },
      series: this.series
    })
  }

  formatterFunction() {
    let f = function() {
      return `<span style="color: ${this.color}">●</span> ${this.series.name}: <b>${this.y}</b><br/>`
    }

    if (this.formatter === "percentage") {
      f = function() {
        return `<span style="color: ${this.color}">●</span> ${this.series.name}: <b>${this.y}%</b><br/>`
      }
    }

    if (this.formatter === "size") {
      f = function() {
        return `<span style="color: ${this.color}">●</span> ${this.series.name}: <b>${byteSize(this.y)}</b><br/>`
      }
    }

    if (this.formatter === "ms") {
      f = function() {
        return `<span style="color: ${this.color}">●</span> ${this.series.name}: <b>${this.y.toFixed(2)} ms</b><br/>`
      }
    }

    return f
  }

  resetZoom() {
    return function(e) {
      if (e.resetSelection) {
        return
      }

      Highcharts.charts.forEach(chart => {
        if (chart !== e.target) {
          chart.zoomOut()
        }
      })
    }
  }

  syncExtremes() {
    return function(e) {
      const thisChart = this.chart;

      if (e.trigger !== "syncExtremes") {
        Highcharts.charts.forEach(chart => {
          if (chart !== thisChart) {
            if (chart.xAxis[0].setExtremes) {
              chart.xAxis[0].setExtremes(e.min, e.max, undefined, false, { trigger: "syncExtremes" })
            }
          }
        })
      }
    }
  }
}
