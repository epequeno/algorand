#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -r ${PRIVNET_DATA}"

PRIVNET_HOME="${ROOT_DIR}/privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

$gcmd network status