data "grafana_data_source" "default" {
  name = var.datasource_name
}

resource "grafana_rule_group" "default" {
  name             = var.alert_name
  folder_uid       = var.grafana_folder_uid
  interval_seconds = 60
  rule {
    name           = var.rule_name == null ? var.alert_name : var.rule_name
    condition      = "C"
    for            = "0s"
    no_data_state  = "NoData"
    exec_err_state = "Alerting"
    labels         = var.alert_tags

    annotations = {
      summary = var.summary
    }

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.default.uid
      // `model` is a JSON blob that sends datasource-specific data.
      // It's different for every datasource. The alert's query is defined here.
      model = jsonencode({
        editorMode    = "code"
        expr          = var.query
        instant       = true
        intervalMs    = 1000
        legendFormat  = "__auto"
        maxDataPoints = 43200
        range         = false
        refId         = "A"
      })
    }

    // The query was configured to obtain data from the last 60 seconds. Let's alert on the average value of that series using a Reduce stage.
    data {
      datasource_uid = -100 //data.grafana_data_source.default.uid
      // You can also create a rule in the UI, then GET that rule to obtain the JSON.
      // This can be helpful when using more complex reduce expressions.
      model  = <<EOT
{"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
EOT
      ref_id = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    // Now, let's use a math expression as our threshold.
    // We want to alert when the value of stage "B" above exceeds 70.
    data {
      datasource_uid = -100 //data.grafana_data_source.default.uid
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$B ${var.math_operator} ${var.threshold}"
        type       = "math"
        refId      = "C"
      })
    }
  }
}
