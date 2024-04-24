locals {
  alert_tags = {
    homelab = "true"
  }
  additional_enabled_tags = {
    cnpg_cluster = [
      "keycloak-database-cluster",
      "grafana-database-cluster",
      "home-assistant-database-cluster",
    ]
  }
}

resource "grafana_contact_point" "default" {
  name = "Default"

  email {
    addresses               = ["szymon.rychu@gmail.com"]
    message                 = <<EOT
{{ len .Alerts.Firing }} alerts are firing!

Alert summaries:
{{ range .Alerts.Firing }}
{{ template "Alert Instance Template" . }}
{{ end }}
EOT
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_message_template" "default" {
  name = "Default"

  template = <<EOT
{{ define "Alert Instance Template" }}
Firing: {{ .Labels.alertname }}
Silence: {{ .SilenceURL }}
{{ end }}
EOT
}

resource "grafana_mute_timing" "default" {
  name = "Default"

  # intervals {
  #   times {
  #     start = "23:00"
  #     end   = "09:00"
  #   }
  # }

  intervals {
    weekdays = ["saturday", "sunday"]
  }
}

resource "grafana_notification_policy" "default" {
  group_by = ["alertname"]
  contact_point   = grafana_contact_point.default.name
  group_wait      = "1m"
  group_interval  = "1m"
  repeat_interval = "1d"
  policy {
    dynamic "matcher" {
      for_each = local.alert_tags
      content {
        label = matcher.key
        match = "="
        value = matcher.value
      }
    }
    dynamic "matcher" {
      for_each = [ for v in local.additional_enabled_tags {v.key: v.value}  ]

      content {
        label = matcher.value.key
        match = "="
        value = matcher.value.
      }
    }
    group_by      = ["alertname"]
    contact_point = grafana_contact_point.default.name
    mute_timings  = [
      grafana_mute_timing.default.name
    ]
  }
}

data "grafana_data_source" "default" {
  name = "Prometheus"
}

resource "grafana_folder" "default" {
  title = "Default"
}

# resource "grafana_rule_group" "default" {
#   name             = "Default"
#   folder_uid       = grafana_folder.default.uid
#   interval_seconds = 60
#   rule {
#     name      = "My Random Walk Alert"
#     condition = "C"
#     for       = "0s"
#     labels    = local.alert_tags

#     data {
#       ref_id = "A"
#       relative_time_range {
#         from = 600
#         to = 0
#       }
#       datasource_uid = data.grafana_data_source.default.uid
#       // `model` is a JSON blob that sends datasource-specific data.
#       // It's different for every datasource. The alert's query is defined here.
#       model = jsonencode({
#         intervalMs = 1000
#         maxDataPoints = 43200
#         refId = "A"
#       })
#     }

#     // The query was configured to obtain data from the last 60 seconds. Let's alert on the average value of that series using a Reduce stage.
#     data {
#       datasource_uid = -100 //data.grafana_data_source.default.uid
#       // You can also create a rule in the UI, then GET that rule to obtain the JSON.
#       // This can be helpful when using more complex reduce expressions.
#       model = <<EOT
# {"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
# EOT
#       ref_id = "B"
#       relative_time_range {
#         from = 0
#         to = 0
#       }
#     }

#     // Now, let's use a math expression as our threshold.
#     // We want to alert when the value of stage "B" above exceeds 70.
#     data {
#       datasource_uid = -100 //data.grafana_data_source.default.uid
#       ref_id = "C"
#       relative_time_range {
#         from = 0
#         to = 0
#       }
#       model = jsonencode({
#         expression = "$B > 70"
#         type = "math"
#         refId = "C"
#       })
#     }
#   }
# }
