#!/usr/bin/env bash
set -euo pipefail

python3 "$1"
npm run build -w @earendil-works/chord
npm run build -w @earendil-works/pi-protocol
npm run build -w @earendil-works/pi-telemetry
npm run build -w @earendil-works/pi-tui
npm run build -w @earendil-works/pi-ai
npm run build -w @earendil-works/pi-agent-core
npm run build -w @earendil-works/pi-client
