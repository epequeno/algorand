#!/usr/bin/env bash

set -x
set -e

source $ALGORAND_HOME/../src/common.sh

$gcmd node stop 
