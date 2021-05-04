#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/../common.sh"

PRIVNET_HOME="${ALGORAND_HOME}/../privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

$gcmd network create -r "${PRIVNET_DATA}" -n private -t "${PRIVNET_HOME}/my_network_template.json"