#!/usr/bin/env bash

set -x
set -e

if [ -z "${PASSPHRASE}" ]; then
	echo "PASSPHRASE not set"
	exit 1
fi

gcmd="${ALGORAND_BIN}/goal -d ${ROOT_DIR}/privnet/net1/Node"

# compile teal file and record its address
contract_address="$(${gcmd} clerk compile ./passphrase.teal | awk '{print $NF}')"

# get user accounts
alice="$(${gcmd} account list | awk '{print $3}' | head -n1)"
bob="$(${gcmd} account list | awk '{print $3}' | tail -n1)"

# check bob balance
echo "bob starting balance"
${gcmd} account balance --address ${bob}

# fund account and confirm contract balance
${gcmd} clerk send --amount 1000000 --from ${alice} --to ${contract_address}
${gcmd} account balance --address ${contract_address}

${gcmd} clerk send \
--amount 30000 \
--from-program ./passphrase.teal \
--close-to ${bob} \
--to ${bob} \
--argb64 "$(echo -n ${PASSPHRASE} | base64 -w 0)" \
--out out.txn

${gcmd} clerk dryrun --txfile out.txn && ${gcmd} clerk rawsend --filename out.txn

# confirm contract has been emptied
echo "contract balance"
${gcmd} account balance --address ${contract_address}

# confirm bob has recieved contract funds
echo "bob ending balance"
${gcmd} account balance --address ${bob}
