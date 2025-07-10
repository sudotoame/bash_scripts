#!/bin/bash

# Скрипт надо запускать через sudo

## Prometheus

config_create() {
	cat <<EOF >/etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

rule_files:
  # - "first_rule"
  # - "second_rule"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
 
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF
}

systemd_create() {
	cat <<EOF >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOF
}

set -e # Скрипт остановится при ошибке

echo "=== Updating the system ==="
apt update && apt upgrade -y

echo "=== Installing dependencies ==="
apt install -y curl wget tar git ufw prometheus-node-exporter stress

# Prometheus version
PROM_VERSION="3.4.1"
echo "=== Download Prometheus ==="
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xvfz prometheus-${PROM_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROM_VERSION}.linux-amd64/

echo "=== Copy Binaries ==="
cp prometheus /usr/local/bin
cp promtool /usr/local/bin
mkdir -p /etc/prometheus /var/lib/prometheus

echo "=== Create a config for Prometheus ==="
config_create

echo "=== Creating user for Prometheus and rights ==="
if ! getent passwd prometheus >/dev/null 2>&1; then
	sudo useradd --no-create-home --shell /bin/false prometheus
fi
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

echo "=== systemd for Prometheus ==="
systemd_create

## Grafana

echo "=== Adding Grafana repository ==="
apt install -y apt-transport-https
apt install -y software-properties-common

echo "=== Install Grafana ==="
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_12.0.1+security~01_amd64.deb
dpkg -i grafana_12.0.1+security~01_amd64.deb
apt-get update && apt-get -y -f install grafana

echo "=== Enabling and Starting Daemons ==="
systemctl daemon-reload
systemctl enable prometheus grafana-server
systemctl start prometheus grafana-server

echo "=== Configure UFW ==="
ufw allow OpenSSH
ufw allow 3000
ufw allow 9090
ufw --force enable

echo "=== Info ==="
echo "Node exporter: http://localhost:9090"
echo "Prometheus: http://localhost:9100"
echo "Grafana: http://localhost:3000"
echo "Login Grafana: admin / admin"
