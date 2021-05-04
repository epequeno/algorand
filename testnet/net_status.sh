#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${ALGORAND_HOME}/../common.sh"

$gcmd -d "${ALGORAND_DATA}" node status -w 1000
