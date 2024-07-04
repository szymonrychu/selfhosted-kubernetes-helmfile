variable "alert_tags" {
  description = "Map of key/values for the alert"
  type        = map(string)
  default     = {}
}

variable "grafana_folder_uid" {
  description = "UID of the grafana_folder object"
  type        = string
}

variable "alert_name" {
  description = "Name of the alert instance"
  type        = string
}

variable "rule_name" {
  description = "Name of the rule in alert instance"
  type        = string
  default     = null
}

variable "datasource_name" {
  description = "Name of the Prometheus datasource to use for alert"
  type        = string
  default     = "Prometheus"
}

variable "query" {
  description = "Query for the alert to trigger on"
  type        = string
}

variable "math_operator" {
  description = "Math operation to compute alert from"
  type        = string
  default     = ">"
}

variable "threshold" {
  description = "Threshold to fire alert"
  type        = number
}

variable "summary" {
  description = "Summary of the alert"
  type        = string
}

variable "for" {
  description = "Amount of time to wait until firing the alert"
  type        = string
  default     = "60s"
}
