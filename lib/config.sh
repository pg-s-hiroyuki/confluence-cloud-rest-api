#!/bin/bash

INSTANCE="{instance name}"
HOST="${INSTANCE}.atlassian.net"
USER="{user}"
PASS="{password}"

function log {
  echo "[INFO] ${1}"
}