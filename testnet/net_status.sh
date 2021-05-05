#!/usr/bin/env bash

gcmd="${ALGORAND_BIN}/goal -d ${TESTNET_DATA}"

${gcmd} node status -w 1000
