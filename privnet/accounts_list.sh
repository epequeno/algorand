#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/../common.sh"

PRIVNET_HOME="${ALGORAND_HOME}/../privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

echo "accounts on Primary"
$gcmd account list -d "${PRIVNET_DATA}/Primary"

echo

echo "accounts on Node"
$gcmd account list -d "${PRIVNET_DATA}/Node"