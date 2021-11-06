#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

$gcmd asset create \
--creator "${TESTNET_CREATOR_ADDRESS}" \
--decimals 0 \
--name NFTDEMO1 \
--unitname demo \
--total 1