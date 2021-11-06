#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

$gcmd asset send \
--amount 1 \
--assetid 21772285 \
--creator "${TESTNET_CREATOR_ADDRESS}" \
--from "${TESTNET_CREATOR_ADDRESS}" \
--to "${TESTNET_ALICE_ADDRESS}" 