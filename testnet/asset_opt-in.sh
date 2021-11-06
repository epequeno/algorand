#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

$gcmd asset send \
--amount 0 \
--assetid 21772285 \
--from "${TESTNET_BOB_ADDRESS}" \
--to "${TESTNET_BOB_ADDRESS}" \
--creator "${TESTNET_CREATOR_ADDRESS}"