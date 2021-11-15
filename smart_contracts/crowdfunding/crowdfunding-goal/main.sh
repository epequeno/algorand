#!/usr/bin/env bash
# https://developer.algorand.org/solutions/example-crowdfunding-stateful-smart-contract-application/

set -x
set -e

# if [ -z "${PASSPHRASE}" ]; then
# 	echo "PASSPHRASE not set"
# 	exit 1
# fi

gcmd="${ALGORAND_BIN}/goal -d ${ROOT_DIR}/privnet/net1/Node"

# Application creation - step 1
# teal programs must be written prior to this
${gcmd} app create \
--creator "${CREATOR_ACCOUNT}" \
--approval-prog ./crowd_fund.teal \
--clear-prog ./crowd_fund_close.teal \
--global-byteslices 3 \
--global-ints 5 \
--local-byteslices 0 \
--local-ints 1 \
--app-arg "int:begintimestamp" \
--app-arg "int:endtimestamp" \
--app-arg "int:1000000" \
--app-arg "addr:${CREATOR_ACCOUNT}" \
--app-arg "int:fundclosedatetimestamp"

# # Application Update - Step 1a
# ${gcmd} app update \
# --app-id "${APP_ID}" \
# --from "${CREATOR_ACCOUNT}" \
# --approval-prog ./crowd_fund.teal \
# --clear-prog ./crowd_fund_close.teal \
# --app-arg "addr:${ADDR}"

# # Application Optin and Donate - Step 2
# ${gcmd} app optin \
# --app-id "${APP_ID}" \
# --from "${CREATOR_ACCOUNT}"

# ${gcmd} app call \
# --app-id "${APP_ID}" \
# --app-arg "str:donate" \
# --from "${CREATOR_ACCOUNT}" \
# --out unsignedtransaction1.tx

# ${gcmd} clerk send \
# --from "${CREATOR_ACCOUNT}" \
# --to "${ADDR}" \
# --amount 500000 \
# --out unsignedtransaction2.tx

# cat unsignedtransaction1.tx unsignedtransaction2 > combinedtransactions.tx

# ${gcmd} clerk group \
# -i combinedtransactions.tx \
# -o groupedtransactions.tx

# ${gcmd} clerk sign \
# -i groupedtransactions.tx \
# -o signout.tx

# ${gcmd} clerk rawsend \
# -f signout.tx

# # Application Call Withdraw Funds - Step 3
# ${gcmd} app call \
# --app-id "${APP_ID}" \
# --app-arg "str:claim" \
# --from "${CREATOR_ACCOUNT}" \
# --out unsignedtransaction1.tx

# ${gcmd} clerk send \
# --to "${CREATOR_ACCOUNT}" \
# --close-to "${CREATOR_ACCOUNT}" \
# --from-program ./crowd_fund_escrow.teal \
# --amount 0 \
# --out unsignedtransaction2.tx 

# cat unsignedtransaction1.tx unsignedtransaction2.tx > combinedtransactions.tx

# ${gcmd} clerk group \
# -i combinedtransactions.tx \
# -o groupedtransactions.tx

# ${gcmd} clerk split \
# -i groupedtransactions.tx \
# -o split.tx

# ${gcmd} clerk sign \
# -i split-0.tx \
# -o signout-0.tx \

# cat signout-0.tx split-1.tx > signout.tx

# ${gcmd} clerk rawsend \
# -f signout.tx

# # Application Call Reclaim Funds - Step 4
# ${gcmd} app call \
# --app-id "${APP_ID}" \
# --app-account "${ADDR}" \
# --app-arg "str:reclaim" \
# --from "${CREATOR_ACCOUNT}" \
# --out unsignedtransaction1.tx

# ${gcmd} clerk send \
# --to "${CREATOR_ACCOUNT}" \
# --close-to "${CREATOR_ACCOUNT}" \
# --from-program ./crowd_fund_escrow.teal \
# --amount 499000 \
# --out unsignedtransaction2.tx

# cat unsignedtransaction1.tx unsignedtransaction2.tx > combinedtransactions.tx

# ${gcmd} clerk group \
# -i combinedtransactions.tx \
# -o groupedtransactions 

# ${gcmd} clerk sign \
# -i split-0.tx \
# -o signout-0.tx \

# cat signout-0.tx split-1.tx > signout.tx

# ${gcmd} clerk rawsend \
# -f signout.tx

# # Application Delete - Step 5
# ${gcmd} app delete \
# --app-id "${APP_ID}" \
# --from "${CREATOR_ACCOUNT}" \
# --app-account "${ADDR}" \
# --out unsignedtransaction1.tx

# ${gcmd} clerk send \
# --from-program ./crowd_fund_escrow.teal \
# --to "${CREATOR_ACCOUNT}" \
# --amount 0 \
# -c "${CREATOR_ACCOUNT}" \
# --out unsignedtransaction2.tx

# cat unsignedtransaction1.tx unsignedtransaction2.tx > combinedtransactions.tx

# ${gcmd} clerk group \
# -i combinedtransactions.tx \
# -o groupedtransactions.tx

# ${gcmd} clerk split \
# -i groupedtransactions.tx \
# -o split.tx

# ${gcmd} clerk sign \
# -i split-0.tx \
# -o signout-0.tx

# cat signout-0.tx split-1.tx > signout.tx

# ${gcmd} clerk rawsend \
# -f signout.tx