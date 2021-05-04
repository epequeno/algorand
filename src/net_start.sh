#!/usr/bin/env bash

set -x
set -e

source $ALGORAND_HOME/../src/common.sh

$gcmd node start
$gcmd node catchup $(curl -s $TESTNET_CATCHUP_URL)
