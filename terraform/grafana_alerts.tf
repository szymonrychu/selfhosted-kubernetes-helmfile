module "root_disk_space" {
  source = "./modules/grafana_alert"

  grafana_folder_uid = grafana_folder.default.uid

  alert_name     = "Root disk too full"
  query          = <<EOF
(1 - avg by (nodename) (node_filesystem_avail_bytes{job="node-exporter", fstype!="", mountpoint="/", })
/
avg by (nodename) (node_filesystem_size_bytes{job="node-exporter", fstype!="", mountpoint="/"}))
* 100
EOF
  threshold      = 80
  decimal_points = 0
  summary        = <<EOF
The server {{ index $labels "nodename" }} has exceeded 80% of available disk space. Disk space used is {{ index $values "B" }}%."
EOF
}

module "nas_samba_disk_space" {
  source = "./modules/grafana_alert"

  grafana_folder_uid = grafana_folder.default.uid

  alert_name     = "Samba too full on NAS"
  query          = <<EOF
(1 - avg by (mountpoint) (node_filesystem_avail_bytes{job="node-exporter", fstype!="", mountpoint="/samba"})
/
avg by (mountpoint) (node_filesystem_size_bytes{job="node-exporter", fstype!="", mountpoint="/samba"}))
* 100
EOF
  threshold      = 80
  decimal_points = 3

  summary = <<EOF
Samba disk in nas server has exceeded 80% of available disk space. Disk space used is {{ index $values "B" }}%.
EOF
}

module "kube_node_not_ready" {
  source = "./modules/grafana_alert"

  grafana_folder_uid = grafana_folder.default.uid

  alert_name     = "Kube Node not ready"
  query          = <<EOF
sum(kube_node_status_condition{status="true", condition="Ready"}) by (node)
EOF
  threshold      = 1
  decimal_points = 0
  math_operator  = "<"

  summary = <<EOF
The server {{ index $labels "node" }} is not Ready.
EOF
}
