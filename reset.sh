#!/usr/bin/env bash

if [ -z "${ALGORAND_BIN}" ] || [ -z "${TESTNET_DATA}" ]; then
	echo "ALGORAND_BIN or TESTNET_DATA not set"
	exit 1
fi


rm -rf "${ALGORAND_BIN}"
rm -rf "${ROOT_DIR}/testnet/data"
rm -rf "${ROOT_DIR}/privnet/net1"
rm ./updater
rm ./update.sh
