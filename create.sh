#!/usr/bin/env bash

set -x
set -e

if [ -z $ALGORAND_HOME ] || [ -z $ALGORAND_DATA ]; then
	echo "ALGORAND_HOME or ALGORAND_DATA not set"
	exit 1
fi


wget https://raw.githubusercontent.com/algorand/go-algorand-doc/master/downloads/installers/update.sh
chmod 700 update.sh
./update.sh -i -c stable -p $ALGORAND_HOME -d $ALGORAND_DATA -n
cp "$ALGORAND_HOME/genesisfiles/testnet/genesis.json" "$ALGORAND_DATA/genesis.json"
