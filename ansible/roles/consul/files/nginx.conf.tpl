user www-data;
worker_processes auto;
pid /run/nginx.pid;
load_module /usr/lib/nginx/modules/ngx_stream_module.so;

events {
	worker_connections 768;
}
stream {

    log_format basic '$remote_addr [$time_local] '
        '$protocol $status $bytes_sent $bytes_received '
        '$session_time "$upstream_addr" '
        '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /var/log/nginx/access.log basic;
    error_log  /var/log/nginx/error.log;

    upstream kubernetes_backend {
        {{- range service "kubernetes" }}
        server {{.Address}}:{{.Port}};
        {{- else }}
        server 127.0.0.1:65535;
        {{- end }}
    }

    server {
        listen 8443;
        proxy_pass kubernetes_backend;
        proxy_next_upstream on;
    }
}

kubeadm init --pod-network-cidr "10.1.0.0/16"   --service-cidr "10.2.0.0/16" --control-plane-endpoint "192.168.1.16:6443" --upload-certs --apiserver-cert-extra-sans "10.8.0.16,10.8.0.17,10.8.0.18,192.168.1.16,192.168.1.17,192.168.1.18,szymonrichert.pl,k8s.szymonrichert.pl,kubernetes.consul,kubernetes.local" --apiserver-advertise-address 192.168.1.16