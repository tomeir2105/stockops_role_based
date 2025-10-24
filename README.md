# StockOps Internal DevOps Documentation

## Overview

StockOps is a complete end-to-end DevOps project designed and built around a multi-node Raspberry Pi cluster.  
It provides a full operational environment that integrates lightweight Kubernetes (K3s), Ansible-based provisioning, Jenkins CI/CD, InfluxDB and Grafana monitoring, and AI-based analytics such as sentiment analysis using FinBERT.

The purpose of StockOps is to demonstrate a practical, self-contained DevOps ecosystem: from infrastructure setup to data analytics and monitoring, all running on small-scale ARM-based devices.

---

## Architecture Summary

The project is organized around four Raspberry Pi nodes:

- **k3srouter** – the control plane node that also serves as NFS server, Jenkins master, and gateway.
- **k3s1**, **k3s2**, **k3s3** – worker nodes that run containers for monitoring, analytics, and data processing.

A shared NFS volume is mounted across nodes, providing persistent storage for services like Jenkins, InfluxDB, and Grafana.

Services run inside K3s pods and communicate over an internal cluster network.

### Core Components

| Component | Description |
|------------|-------------|
| **K3s** | Lightweight Kubernetes distribution for ARM devices |
| **Ansible** | Used for provisioning, configuration management, and orchestration |
| **Jenkins** | Continuous Integration server handling CI/CD pipelines |
| **InfluxDB** | Time-series database for metrics and analytics data |
| **Grafana** | Dashboard visualization platform connected to InfluxDB |
| **Netdata** | Real-time node-level monitoring |
| **FinBERT** | AI model for sentiment analysis of financial news |
| **Python Services** | Custom scripts that fetch news and stock data, push results to InfluxDB |

---

## Repository Layout

```
roles/                  # Modular Ansible roles (each represents one logical task group)
playbooks/              # Grouped playbooks for environment, monitoring, CI, news, sentiments
RUNS/                   # Run scripts and ready-made commands
inventory.ini           # Example inventory for cluster hosts
ansible.cfg             # Default Ansible configuration
site.yml                # Aggregated playbook applying all roles
```

Each role inside `roles/` represents a standalone part of the infrastructure, allowing independent execution and reuse.

---

## How to Use

### Prerequisites

- Ansible 2.15+ installed on your management host (can be any Linux system)
- SSH key-based authentication set up between management host and Raspberry Pi nodes
- Python 3 installed on all nodes
- NFS server configured on the router node

### Step 1: Update Inventory

Edit `inventory.ini` with your real hostnames and users. Example:

```ini
[k3s_router]
k3srouter ansible_host=192.168.68.1 ansible_user=pi

[k3s_nodes]
k3s1 ansible_host=192.168.68.11 ansible_user=pi
k3s2 ansible_host=192.168.68.12 ansible_user=pi
k3s3 ansible_host=192.168.68.13 ansible_user=pi

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Step 2: Check Connectivity

```bash
ansible all -m ping
```

If you receive “pong” responses from all hosts, your setup is ready.

### Step 3: Run the Complete Stack

```bash
ansible-playbook site.yml --become
```

This command runs all available roles in logical order, installing and configuring every component automatically.

---

## Modular Run Options

You can also execute specific stacks using the prepared playbooks under `playbooks/`:

### 1. Environment Setup
```bash
ansible-playbook playbooks/run_environment.yml
```
Installs system dependencies, configures NFS folders, ensures SSH and time synchronization, and prepares Docker/K3s base.

### 2. Monitoring Stack
```bash
ansible-playbook playbooks/run_monitoring.yml
```
Sets up InfluxDB, Grafana, Netdata, and related dashboards.

### 3. CI Stack (Jenkins)
```bash
ansible-playbook playbooks/run_ci.yml
```
Deploys Jenkins master (on k3srouter) and agents on worker nodes with SSH and Java preinstalled.

### 4. News Pipeline
```bash
ansible-playbook playbooks/run_news.yml
```
Deploys the Python service that retrieves news data and pushes results to InfluxDB.

### 5. Sentiments Pipeline
```bash
ansible-playbook playbooks/run_sentiments.yml
```
Deploys the FinBERT sentiment analysis pod and configures its checkpoint, log, and output directories.

---

## One-Off Role Examples

You can also execute individual roles directly. For example:

```bash
ansible-playbook playbooks/run_role_deploy-jenkins.yml
ansible-playbook playbooks/run_role_check-influxdb.yml
ansible-playbook playbooks/run_role_create-grafana-token.yml
```

---

## Run Scripts

The `RUNS/scripts/` directory contains shell shortcuts for quick execution.

Examples:

```bash
./RUNS/scripts/run_all.sh          # Full stack deployment
./RUNS/scripts/run_environment.sh  # Infrastructure setup
./RUNS/scripts/run_monitoring.sh   # Monitoring stack
./RUNS/scripts/run_ci.sh           # Jenkins deployment
```

You can modify these scripts to include additional parameters such as `-vv` for verbose output or `--limit` for partial host execution.

---

## Customization and Variables

Global variables can be found or added in `group_vars/all.yml`.  
Typical values include paths for shared storage, credentials, API tokens, and NFS mount locations.

Example variable block:

```yaml
APP_DIRS:
  - { path: "/mnt/nfs/jenkins", owner: "1000", group: "1000", mode: "0770" }
  - { path: "/mnt/nfs/grafana", owner: "472", group: "472", mode: "02775" }
  - { path: "/mnt/nfs/influxdb", owner: "1000", group: "1000", mode: "2700" }
```

---

## Operational Flow

1. **Stage 0–2:** Environment setup (network, SSH, NFS, K3s installation).  
2. **Stage 3–4:** Jenkins installation and agent linking.  
3. **Stage 5–6:** Monitoring stack (Netdata, InfluxDB, Grafana).  
4. **Stage 7–8:** Application-level deployments (news, sentiments).  
5. **Stage 9:** Verification checks and cleanup routines.

Each stage can be re-run safely due to idempotent task design.

---

## Maintenance Commands

Useful commands for ongoing maintenance:

```bash
# View pod status
kubectl get pods -A -o wide

# Restart all K3s services
systemctl restart k3s

# Check NFS mounts
showmount -e 192.168.68.1

# Verify Jenkins token
ansible-playbook playbooks/run_role_print-crumb.yml

# Clean old pods and PVCs
ansible-playbook playbooks/run_role_down-all-pods.yml
```

---

## Future Improvements

- Replace manual token management with dynamic secret injection
- Integrate Traefik/Flagger for canary deployments
- Add Prometheus exporter for FinBERT metrics
- Create automated backup role for InfluxDB and Jenkins volumes

---

## Author Notes

This repository represents the working state of the StockOps project as deployed on the Raspberry Pi cluster.  
It evolved through multiple iterations to achieve a clean, modular, role-based Ansible design that mirrors enterprise DevOps practices but runs fully offline on small hardware.

Author: **Meir A.**  
GitHub: [tomeir2105](https://github.com/tomeir2105)  
Docker Hub: [meir25](https://hub.docker.com/u/meir25)

For questions or improvements, update this repository and use pull requests or issue tracking.
