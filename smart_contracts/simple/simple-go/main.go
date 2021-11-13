package main

import (
	"context"
	"fmt"
	"os"

	"github.com/algorand/go-algorand-sdk/client/v2/algod"
	"github.com/algorand/go-algorand-sdk/crypto"
	"github.com/algorand/go-algorand-sdk/future"
)

func main() {
	ctx := context.Background()
	algodAddress := os.Getenv("SANDBOX_ALGOD_ADDRESS")
	algodToken := os.Getenv("SANDBOX_ALGOD_TOKEN")
	if algodAddress == "" || algodToken == "" {
		fmt.Println("env vars are not set!")
		return
	}

	// build clients
	algodClient, err := algod.MakeClient(algodAddress, algodToken)
	if err != nil {
		fmt.Printf("failed to make algod client: %s\n", err)
		return
	}

	// create contract account
	dat, err := os.ReadFile("./passphrase.teal")
	if err != nil {
		panic(err)
	}
	compiledTeal, err := algodClient.TealCompile(dat).Do(ctx)
	if err != nil {
		panic(err)
	}
	lsig := crypto.MakeLogicSigAccountEscrow([]byte(compiledTeal.Result), [][]byte{})
	sp, err := algodClient.SuggestedParams().Do(ctx)
	if err != nil {
		panic(err)
	}
	var note []byte
	future.MakePaymentTxn("", "", 0, note, "", sp)
	// alice funds escrow

	// obtain a handle to our wallet and sign txn

	// submit transaction

	// provide password to lsig and submit contract signed transaction

}
