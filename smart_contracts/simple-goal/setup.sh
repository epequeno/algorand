#!/usr/bin/env bash

set -x
set -e

PRIVNET_DATA="${ROOT_DIR}/privnet/net1"

# remove any existing data
if [ -d "${PRIVNET_DATA}" ]; then
    "${ROOT_DIR}/privnet/net_stop.sh"
    "${ROOT_DIR}/privnet/net_delete.sh"
fi

# create new private network
"${ROOT_DIR}/privnet/net_create.sh"
"${ROOT_DIR}/privnet/net_start.sh"