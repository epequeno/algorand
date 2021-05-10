package main

import (
	"fmt"
	"os"

	"github.com/algorand/go-algorand-sdk/client/algod"
)

func main() {
	algodAddress := os.Getenv("ALGOD_ADDRESS")
	algodToken := os.Getenv("ALGOD_TOKEN")
	if algodAddress == "" || algodToken == "" {
		fmt.Println("env vars are not set!")
		return
	}

	algodClient, err := algod.MakeClient(algodAddress, algodToken)
	if err != nil {
		fmt.Printf("failed to make algod client: %s\n", err)
		return
	}

	nodeStatus, err := algodClient.Status()
	if err != nil {
		fmt.Println("oops")
		return
	}

	fmt.Println(nodeStatus.LastRound)

}
