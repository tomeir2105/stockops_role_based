#!/usr/bin/env bash
set -euo pipefail

ansible-playbook playbooks/run_role_check-influxdb.yml
