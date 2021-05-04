#!/usr/bin/env bash

set -x
set -e

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/../common.sh"

$gcmd -d "${ALGORAND_DATA}" node start
$gcmd -d "${ALGORAND_DATA}" node catchup "$(curl -s ${TESTNET_CATCHUP_URL})"
