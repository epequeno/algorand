#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"
TESTNET_CATCHUP_URL="https://algorand-catchpoints.s3.us-east-2.amazonaws.com/channel/testnet/latest.catchpoint"

$gcmd node start
$gcmd node catchup "$(curl -s ${TESTNET_CATCHUP_URL})"
