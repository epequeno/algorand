#!/usr/bin/env bash

# Gets the latest binaries and puts them into a common place

set -x
set -e

if [ -z "${ALGORAND_BIN}" ] || [ -z "${TESTNET_DATA}" ]; then
	echo "ALGORAND_BIN or TESTNET_DATA not set"
	exit 1
fi


wget https://raw.githubusercontent.com/algorand/go-algorand-doc/master/downloads/installers/update.sh
chmod 700 update.sh
./update.sh -i -c stable -p "${ALGORAND_BIN}" -d "${TESTNET_DATA}" -n
cp "${ALGORAND_BIN}/genesisfiles/testnet/genesis.json" "${TESTNET_DATA}"