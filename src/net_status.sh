#!/usr/bin/env bash

source $ALGORAND_HOME/../src/common.sh

$gcmd node status -w 1000
