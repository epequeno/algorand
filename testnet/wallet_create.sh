#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

for name in creator alice bob; do
    ${gcmd} wallet new "${name}"
done