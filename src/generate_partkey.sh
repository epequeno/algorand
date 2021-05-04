#!/usr/bin/env bash

set -x
set -e

source $ALGORAND_HOME/../src/common.sh

if ! $gcmd node status 1>&2 > /dev/null; then
	echo "failed getting node status; is node running?"
	exit 1
fi

#$gcmd account addpartkey
