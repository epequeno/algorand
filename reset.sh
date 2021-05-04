#!/usr/bin/env bash

if [ -z "$ALGORAND_HOME" ] || [ -z "$ALGORAND_DATA" ]; then
	echo "ALGORAND_HOME or ALGORAND_DATA not set"
	exit 1
fi


rm -rf "$ALGORAND_HOME"
rm ./updater
rm ./update.sh
