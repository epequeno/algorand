# set env vars and aliases for CLI use

set -gx ROOT_DIR (pwd)
set -gx ALGORAND_BIN $ROOT_DIR/bin
set -gx TESTNET_DATA $ROOT_DIR/testnet/data

function gcmd
	$ALGORAND_BIN/goal $argv
end
