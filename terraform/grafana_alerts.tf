module "root_disk_space" {
  source = "./modules/grafana_alert"

  grafana_folder_uid = grafana_folder.default.uid

  alert_name = "Root disk too full"
  query      = <<EOF
1 - avg by (nodename) (node_filesystem_avail_bytes{job="node-exporter", fstype!="", mountpoint="/", })
/
avg by (nodename) (node_filesystem_size_bytes{job="node-exporter", fstype!="", mountpoint="/"})
EOF
  threshold  = 0.8
}

module "nas_samba_disk_space" {
  source = "./modules/grafana_alert"

  grafana_folder_uid = grafana_folder.default.uid

  alert_name = "Samba too full on NAS"
  query      = <<EOF
1 - avg by (mountpoint) (node_filesystem_avail_bytes{job="node-exporter", fstype!="", mountpoint="/samba"})
/
avg by (mountpoint) (node_filesystem_size_bytes{job="node-exporter", fstype!="", mountpoint="/samba"})
EOF
  threshold  = 0.8
}
