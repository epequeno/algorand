#!/usr/bin/env bash

set -x
set -e

gcmd="${ALGORAND_BIN}/goal -d ${ROOT_DIR}/privnet/net1/Node"

# compile teal file and record its address
contract_address="$(${gcmd} clerk compile ./passphrase.teal | awk '{print $NF}')"

# get user accounts
alice="$(${gcmd} account list | awk '{print $3}' | head -n1)"
bob="$(${gcmd} account list | awk '{print $3}' | tail -n1)"

${gcmd} clerk send --amount 1000000 --from ${alice} --to ${contract_address}

# confirm contract has been funded
${gcmd} account balance --address ${contract_address}

${gcmd} clerk send \
--amount 30000 \
--from-program ./passphrase.teal \
--close-to ${bob} \
--to ${bob} \
--argb64 "$(echo -n ${PASSPHRASE} | base64 -w 0)" \
--out out.txn

${gcmd} clerk dryrun -t out.txn && ${gcmd} clerk rawsend --filename out.txn

# confirm contract has been emptied
${gcmd} account balance --address ${contract_address}