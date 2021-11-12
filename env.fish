# set env vars and aliases for CLI use

set -gx ROOT_DIR (pwd)
set -gx ALGORAND_BIN $ROOT_DIR/bin
set -gx TESTNET_DATA $ROOT_DIR/testnet/data
set -gx PRIVNET_DATA $ROOT_DIR/privnet/net1/Node

# sandbox 
set -gx SANDBOX_ALGOD_ADDRESS http://localhost:4001
set -gx SANDBOX_KMD_ADDRESS http://localhost:4002
set -gx SANDBOX_INDEXER_ADDRESS http://localhost:8980

# privnet 
set -gx PRIVNET_ALGOD_ADDRESS http://localhost:4001
set -gx PRIVNET_KMD_ADDRESS http://localhost:4002
set -gx PRIVNET_INDEXER_ADDRESS http://localhost:8980

#  testnet 
set -gx TESTNET_ALGOD_ADDRESS http://localhost:4001
set -gx TESTNET_KMD_ADDRESS http://localhost:4002
set -gx TESTNET_INDEXER_ADDRESS http://localhost:8980

# mainnet 
set -gx MAINNET_ALGOD_ADDRESS http://localhost:4001
set -gx MAINNET_KMD_ADDRESS http://localhost:4002
set -gx MAINNET_INDEXER_ADDRESS http://localhost:8980

set -gx PATH $PATH $ALGORAND_BIN
