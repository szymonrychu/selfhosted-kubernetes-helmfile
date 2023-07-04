#!/bin/bash
set -euo pipefail

ensure_etc_host() {
  local hostname="${1}"
  local ip="${2}"
  if ! grep -q "${ip} ${hostname}" /etc/hosts; then
    echo "${ip} ${hostname}" >> /etc/hosts
  fi
}

package_installed() {
  local package_name="${1}"
  if [[ "$(/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' "${package_name}" 2> /dev/null)" == "installed" ]]; then
    return 0
  else
    return 1
  fi
}

ensure_package() {
  local package_name="${1}"
  if package_installed "${package_name}"; then
    return
  fi
  apt-get update
  apt-get install -yq "${package_name}"
}

install_docker_ce() {
  if package_installed "docker-ce"; then
    return
  fi
  apt-get update
  apt-get install -yq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -yq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  mkdir -p /etc/containerd
  containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/g' > /etc/containerd/config.toml
  systemctl restart containerd
}

install_kube_components() {
  if package_installed "kubeadm"; then
    return
  fi
  apt-get update
  apt-get install -yq \
    apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  local installable_version="$(apt-cache policy kubeadm | grep "${KUBERNETES_VERSION}" | awk '{print $1}')"
  apt-get install -yq --allow-downgrades --allow-change-held-packages \
    "kubelet=${installable_version}" \
    "kubeadm=${installable_version}" \
    kubernetes-cni
  apt-mark hold kubelet kubeadm kubectl
}

configure_keepalived() {
  ensure_package keepalived
  cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
  router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
  state ${STATE}
  interface ${INTERFACE}
  virtual_router_id ${ROUTER_ID}
  priority ${PRIORITY}
  authentication {
    auth_type PASS
    auth_pass ${AUTH_PASS}
  }
  virtual_ipaddress {
    ${APISERVER_VIP}
  }
  track_script {
    check_apiserver
  }
}
EOF
  cat <<EOF > /etc/keepalived/check_apiserver.sh
#!/bin/sh

errorExit() {
  echo "*** $*" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${APISERVER_VIP}; then
  curl --silent --max-time 2 --insecure https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/"
fi
EOF
  systemctl enable keepalived
  systemctl start keepalived
}

configure_haproxy() {
  ensure_package haproxy
  cat <<EOF > /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
  log /dev/log local0
  log /dev/log local1 notice
  daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
  mode                    http
  log                     global
  option                  httplog
  option                  dontlognull
  option http-server-close
  option forwardfor       except 127.0.0.0/8
  option                  redispatch
  retries                 1
  timeout http-request    10s
  timeout queue           20s
  timeout connect         5s
  timeout client          20s
  timeout server          20s
  timeout http-keep-alive 10s
  timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the control plane nodes
#---------------------------------------------------------------------
frontend apiserver
  bind *:${APISERVER_DEST_PORT}
  mode tcp
  option tcplog
  default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance     roundrobin
    server ${HOST1_ID} ${HOST1_ADDRESS}:6443 check
    server ${HOST2_ID} ${HOST2_ADDRESS}:6443 check
    server ${HOST3_ID} ${HOST3_ADDRESS}:6443 check
EOF
  systemctl enable haproxy
  systemctl start haproxy
}

get_ip_by_interface() {
  local interface="${1}"
  ip -f inet addr show "${interface}" | sed -En -e 's/.*inet ([0-9.]+).*/\1/p' | head -1
}

readonly MASTER_HOSTNAME="nuc1"       # master host for cluster
readonly INTERFACE="eno1"             # is the network interface taking part in the negotiation of the virtual IP, e.g. eth0.
readonly ROUTER_ID="51"               # should be the same for all keepalived cluster hosts while unique amongst all clusters in the same subnet. Many distros pre-configure its value to 51.
readonly PRIORITY="101"               # should be higher on the control plane node than on the backups. Hence 101 and 100 respectively will suffice.
readonly AUTH_PASS="42"               # should be the same for all keepalived cluster hosts, e.g. 42

readonly APISERVER_VIP="192.168.1.64"  # is the virtual IP address negotiated between the keepalived cluster hosts.
readonly APISERVER_DEST_PORT="8443"   # the port through which Kubernetes will talk to the API Server.
readonly APISERVER_HOSTNAME="kubernetes.lan" # the port through which Kubernetes will talk to the API Server.

readonly HOST1_ID="nuc1"              # a symbolic name for the first load-balanced API Server host
readonly HOST1_ADDRESS="nuc1.lan" # a resolvable address (DNS name, IP address) for the first load-balanced API Server host
readonly HOST2_ID="nuc2"              # a symbolic name for the first load-balanced API Server host
readonly HOST2_ADDRESS="nuc2.lan" # a resolvable address (DNS name, IP address) for the first load-balanced API Server host
readonly HOST3_ID="nuc3"              # a symbolic name for the first load-balanced API Server host
readonly HOST3_ADDRESS="nuc3.lan" # a resolvable address (DNS name, IP address) for the first load-balanced API Server host

readonly KUBERNETES_SANS="szymonrichert.pl,kubernetes.lan"
readonly KUBERNETES_VERSION="1.25.6"
readonly KUBERNETES_TOKEN="nms1cr.7qbkasmennrksps4"


if [[ "${MASTER_HOSTNAME}" == "$(hostname)" ]]; then
  readonly STATE="MASTER"               # is MASTER for one and BACKUP for all other hosts, hence the virtual IP will initially be assigned to the MASTER.
else
  readonly STATE="BACKUP"               # is MASTER for one and BACKUP for all other hosts, hence the virtual IP will initially be assigned to the MASTER.
fi
readonly CURRENT_MAIN_IP="$(get_ip_by_interface "${INTERFACE}")"
readonly KUBERNETES_EXTRA_SANS="${HOST1_ADDRESS},${HOST2_ADDRESS},${HOST3_ADDRESS},${APISERVER_HOSTNAME},${KUBERNETES_SANS}" # a resolvable address (DNS name, IP address) for the first load-balanced API Server host



install_docker_ce
configure_keepalived
configure_haproxy
install_kube_components
ensure_etc_host "${APISERVER_HOSTNAME}" "${APISERVER_VIP}"


if [[ "${MASTER_HOSTNAME}" == "$(hostname)" ]]; then
  kubeadm init \
    --apiserver-bind-port 6443 \
    --pod-network-cidr 10.244.0.0/16 \
    --control-plane-endpoint "${APISERVER_VIP}:${APISERVER_DEST_PORT}" \
    --apiserver-cert-extra-sans "${KUBERNETES_EXTRA_SANS}" \
    --kubernetes-version "${KUBERNETES_VERSION}" \
    --token "${KUBERNETES_TOKEN}" \
    --token-ttl 0 \
    --upload-certs
  sleep 10
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
fi
