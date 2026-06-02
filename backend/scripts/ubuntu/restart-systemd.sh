#!/usr/bin/env bash
set -euo pipefail

sudo systemctl restart tabecar-api.service
sudo systemctl status tabecar-api.service --no-pager
