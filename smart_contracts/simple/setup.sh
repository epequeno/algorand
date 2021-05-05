#!/usr/bin/env bash

set -x
set -e

# remove any existing data
$ROOT_DIR/privnet/net_stop.sh
$ROOT_DIR/privnet/net_delete.sh

# create new private network
$ROOT_DIR/privnet/net_create.sh
$ROOT_DIR/privnet/net_start.sh