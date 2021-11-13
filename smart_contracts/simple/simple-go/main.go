// implementation of https://developer.algorand.org/tutorials/writing-simple-smart-contract/
package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/algorand/go-algorand-sdk/client/kmd"
	"github.com/algorand/go-algorand-sdk/client/v2/algod"
	"github.com/algorand/go-algorand-sdk/crypto"
	"github.com/algorand/go-algorand-sdk/future"
)

// from https://github.com/algorand-devrel/ASA-Tutorial/blob/5a81d00b86915839667779007fa4c4a1de645ed5/completed%20code/Go/TutorialASA/TutorialASA.go#L68
func waitForConfirmation(algodClient algod.Client, txID string) {
	ctx := context.Background()
	nodeStatus, err := algodClient.Status().Do(ctx)
	if err != nil {
		fmt.Printf("error getting algod status: %s\n", err)
		return
	}
	lastRound := nodeStatus.LastRound
	for {
		pt, _, err := algodClient.PendingTransactionInformation(txID).Do(ctx)
		if err != nil {
			fmt.Printf("waiting for confirmation... (pool error, if any): %s\n", err)
			continue
		}
		if pt.ConfirmedRound > 0 {
			fmt.Printf("Transaction "+txID+" confirmed in round %d\n\n", pt.ConfirmedRound)
			break
		}
		lastRound++
		algodClient.StatusAfterBlock(lastRound)
	}
}

func get_balance(algodClient algod.Client, addr string) uint64 {
	ctx := context.Background()
	acctInfo, err := algodClient.AccountInformation(addr).Do(ctx)
	if err != nil {
		return 0
	}
	return acctInfo.Amount
}

func print_status(algodClient algod.Client, alice, bob, contract string) {
	fmt.Printf("alice: %d\n", get_balance(algodClient, alice))
	fmt.Printf("bob: %d\n", get_balance(algodClient, bob))
	fmt.Printf("contract: %d\n\n", get_balance(algodClient, contract))
}

func main() {
	// the players
	alice := os.Getenv("ALICE")
	bob := os.Getenv("BOB")

	// get config from env
	ctx := context.Background()
	algodAddress := os.Getenv("SANDBOX_ALGOD_ADDRESS")
	algodToken := os.Getenv("SANDBOX_ALGOD_TOKEN")
	kmdAddress := os.Getenv("SANDBOX_KMD_ADDRESS")
	kmdToken := os.Getenv("SANDBOX_KMD_TOKEN")
	if algodAddress == "" || algodToken == "" || kmdAddress == "" || kmdToken == "" {
		fmt.Println("env vars are not set!")
		return
	}

	// build clients
	algodClient, err := algod.MakeClient(algodAddress, algodToken)
	if err != nil {
		fmt.Printf("failed to make algod client: %s\n", err)
		return
	}
	kmdClient, err := kmd.MakeClient(kmdAddress, kmdToken)
	if err != nil {
		fmt.Printf("failed to make kmd client: %s\n", err)
		return
	}

	// create contract account
	file, err := os.Open("./passphrase.teal")
	if err != nil {
		fmt.Printf("failed to read teal file: %s\n", err)
		return
	}
	defer file.Close()
	tealFile, err := ioutil.ReadAll(file)
	if err != nil {
		fmt.Printf("failed to teal file: %s\n", err)
		return
	}
	compiledTeal, err := algodClient.TealCompile(tealFile).Do(ctx)
	if err != nil {
		fmt.Printf("failed to compile teal: %s\n", err)
		return
	}
	program, err := base64.StdEncoding.DecodeString(compiledTeal.Result)
	if err != nil {
		fmt.Printf("failed to b64 compiled teal: %s\n", err)
		return
	}
	args := make([][]byte, 1)
	args[0] = []byte(os.Getenv("PASSPHRASE"))
	lsig := crypto.MakeLogicSigAccountEscrow(program, args)
	lsigAddress, err := lsig.Address()
	if err != nil {
		fmt.Printf("failed to get lsig address: %s\n", err)
		return
	}

	fmt.Println("starting balances")
	print_status(*algodClient, alice, bob, lsigAddress.String())

	// alice funds escrow
	sp, err := algodClient.SuggestedParams().Do(ctx)
	if err != nil {
		fmt.Printf("failed to get suggested params: %s\n", err)
		return
	}
	var note []byte
	txn, err := future.MakePaymentTxn(alice, lsigAddress.String(), 1_000_000, note, "", sp)
	if err != nil {
		fmt.Printf("failed to make payment txn: %s\n", err)
		return
	}

	// obtain a handle to our wallet and sign txn
	listResponse, err := kmdClient.ListWallets()
	if err != nil {
		fmt.Printf("error listing wallets: %s\n", err)
		return
	}
	var defaultWalletID string
	for _, wallet := range listResponse.Wallets {
		if wallet.Name == "unencrypted-default-wallet" {
			defaultWalletID = wallet.ID
			break
		}
	}
	initResponse, err := kmdClient.InitWalletHandle(defaultWalletID, "")
	if err != nil {
		fmt.Printf("Error initializing wallet handle: %s\n", err)
		return
	}
	exampleWalletHandleToken := initResponse.WalletHandleToken
	signResponse, err := kmdClient.SignTransaction(exampleWalletHandleToken, "", txn)
	if err != nil {
		fmt.Printf("Failed to sign transaction with kmd: %s\n", err)
		return
	}
	txid, err := algodClient.SendRawTransaction(signResponse.SignedTransaction).Do(ctx)
	if err != nil {
		fmt.Printf("failed to send fund contract transaction: %s\n", err)
		return
	}
	fmt.Println("alice funds contract")
	waitForConfirmation(*algodClient, txid)
	print_status(*algodClient, alice, bob, lsigAddress.String())

	// close to bob
	sp, err = algodClient.SuggestedParams().Do(ctx)
	if err != nil {
		fmt.Printf("failed to get suggested params: %s\n", err)
		return
	}
	txn, err = future.MakePaymentTxn(lsigAddress.String(), bob, 0, note, bob, sp)
	if err != nil {
		fmt.Printf("failed to make close to bob transaction: %s\n", err)
		return
	}
	_, stx, err := crypto.SignLogicsigTransaction(lsig.Lsig, txn)
	if err != nil {
		fmt.Printf("Signing failed with %v", err)
		return
	}

	txid, err = algodClient.SendRawTransaction(stx).Do(ctx)
	if err != nil {
		fmt.Printf("Sending failed with %v\n", err)
	}

	fmt.Println("close contract")
	waitForConfirmation(*algodClient, txid)
	print_status(*algodClient, alice, bob, lsigAddress.String())

}
