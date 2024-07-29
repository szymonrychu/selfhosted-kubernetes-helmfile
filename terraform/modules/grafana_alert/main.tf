data "grafana_data_source" "default" {
  name = var.datasource_name
}

resource "grafana_rule_group" "default" {
  name             = var.alert_name
  folder_uid       = var.grafana_folder_uid
  interval_seconds = 60
  rule {
    name           = var.rule_name == null ? var.alert_name : var.rule_name
    condition      = "D"
    for            = var.for
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

    data {
      ref_id         = "B"
      datasource_uid = -100
      model = jsonencode({
        conditions = [
          {
            type = "query"
            evaluator = {
              params = []
              type   = "gt"
            }
            operator = {
              type = "and"
            }
            query = {
              params = ["B"]
            }
            reducer = {
              params = []
              type   = "last"
            }
          }
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "A",
        intervalMs    = 1000
        maxDataPoints = 43200
        type          = "reduce"
        reducer       = "last"
        refId         = "B"
      })
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = -100 //data.grafana_data_source.default.uid
      // You can also create a rule in the UI, then GET that rule to obtain the JSON.
      // This can be helpful when using more complex reduce expressions.
      model = jsonencode({
        conditions = [
          {
            type = "query"
            evaluator = {
              params = [0, 0]
              type   = "gt"
            }
            operator = {
              type = "and"
            }
            query = {
              params = []
            }
            reducer = {
              params = []
              type   = "avg"
            }
          }
        ]
        datasource = {
          name = "Expression"
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "round($B*${pow(10, var.decimal_points)})/${pow(10, var.decimal_points)}",
        intervalMs    = 1000
        maxDataPoints = 43200
        hide          = false
        type          = "math"
        refId         = "C"
      })
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    // Now, let's use a math expression as our threshold.
    // We want to alert when the value of stage "B" above exceeds 70.
    data {
      ref_id         = "D"
      datasource_uid = -100 //data.grafana_data_source.default.uid
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$C ${var.math_operator} ${var.threshold}"
        type       = "math"
        refId      = "C"
      })
    }
  }
}
