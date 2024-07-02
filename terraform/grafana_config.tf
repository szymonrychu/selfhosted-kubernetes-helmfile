locals {
  alert_tags = {
    homelab = "true"
  }
  # additional_enabled_tags = {}
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
  group_by        = ["alertname"]
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
    group_by      = ["alertname"]
    contact_point = grafana_contact_point.default.name
    mute_timings = [
      grafana_mute_timing.default.name
    ]
  }
}

resource "grafana_folder" "default" {
  title = "Default"
}
