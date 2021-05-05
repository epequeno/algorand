#!/usr/bin/env bash

set -x
set -e

PRIVNET_HOME="${ROOT_DIR}/privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

gcmd="${ALGORAND_BIN}/goal"

echo "accounts on Primary"
$gcmd account list -d "${PRIVNET_DATA}/Primary"

echo

echo "accounts on Node"
$gcmd account list -d "${PRIVNET_DATA}/Node"