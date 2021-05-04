#!/usr/bin/env bash

set -x
set -e

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/common.sh"

if ! $gcmd -d "${ALGORAND_DATA}" node status 1>&2 > /dev/null; then
	echo "failed getting node status; is node running?"
	exit 1
fi


