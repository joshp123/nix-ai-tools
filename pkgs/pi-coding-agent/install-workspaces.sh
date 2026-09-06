#!/usr/bin/env bash
set -euo pipefail

cp -R packages/chord "$1/node_modules/@earendil-works/chord"
cp -R packages/protocol "$1/node_modules/@earendil-works/pi-protocol"
cp -R packages/telemetry "$1/node_modules/@earendil-works/pi-telemetry"
cp -R packages/client "$1/node_modules/@earendil-works/pi-client"
