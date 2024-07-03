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
{{ template "alerts.message" . }}
EOT
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_message_template" "default" {
  name = "Default"

  template = <<EOT
{{ define "alerts.message" -}}
{{ if .Alerts.Firing -}}
{{ len .Alerts.Firing }} firing alert(s):

{{ template "alerts.summarize_with_links" .Alerts.Firing }}
{{- end }}
{{- if .Alerts.Resolved -}}
{{ len .Alerts.Resolved }} resolved alert(s):

{{ template "alerts.summarize_with_links" .Alerts.Resolved }}
{{- end }}
{{- end }}

{{ define "alerts.summarize_with_links" -}}
{{ range . -}}
{{ index .Annotations "summary" }}
{{- if eq .Status "firing" }} - Silence this alert: {{ .SilenceURL }}{{ end }}
  - View on Grafana: {{ .GeneratorURL }}

{{ end }}
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
