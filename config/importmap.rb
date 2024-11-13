pin "@hotwired/turbo", to: "https://ga.jspm.io/npm:@hotwired/turbo@8.0.12/dist/turbo.es2017-esm.js"
pin "@hotwired/turbo-rails", to: "https://ga.jspm.io/npm:@hotwired/turbo-rails@8.0.12/app/javascript/turbo/index.js"
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@stimulus-components/reveal", to: "https://ga.jspm.io/npm:@stimulus-components/reveal@5.0.0/dist/stimulus-reveal-controller.mjs"
pin "highcharts", to: "https://ga.jspm.io/npm:highcharts@11.0.1/highcharts.js"
pin "byte-size", to: "https://ga.jspm.io/npm:byte-size@9.0.0/index.js"

pin "application", to: "solid_telemetry/application.js", preload: true
pin_all_from SolidTelemetry::Engine.root.join("app/javascript/solid_telemetry/controllers"), under: "controllers", to: "solid_telemetry/controllers"
