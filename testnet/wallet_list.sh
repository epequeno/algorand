#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal"

echo "accounts"
$gcmd wallet list -d "${TESTNET_DATA}"