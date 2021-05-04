#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/../common.sh"

PRIVNET_HOME="${ALGORAND_HOME}/../privnet"
PRIVNET_DATA="${PRIVNET_HOME}/net1"

$gcmd network stop -r "${PRIVNET_DATA}"