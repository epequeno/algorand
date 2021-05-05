#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

$gcmd node stop 
