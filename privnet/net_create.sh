#!/usr/bin/env bash

set -x
set -e

PRIVNET_HOME="${ROOT_DIR}/privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

gcmd="${ALGORAND_BIN}/goal -r ${PRIVNET_DATA}"

$gcmd network create -n private -t "${PRIVNET_HOME}/my_network_template.json"