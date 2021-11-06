# stdlib
from dataclasses import dataclass
from enum import Enum, auto
from os import environ
from typing import Optional
import base64

# 3rd party
from pyteal import (
    Int,
    Bytes,
    Txn,
    compileTeal,
    Mode,
    And,
    Len,
    Arg,
    Sha256,
)
from algosdk import kmd
from algosdk.future.transaction import PaymentTxn, LogicSigAccount, LogicSigTransaction
from algosdk.v2client import algod, indexer


# local


@dataclass
class EnvironmentConfig:
    algod_address: str
    algod_token: str
    kmd_address: str
    kmd_token: str
    indexer_address: str


class Environment(Enum):
    SANDBOX = auto()
    PRIVNET = auto()
    TESTNET = auto()
    MAINNET = auto()

    def config_from_env(self):
        env = "SANDBOX"  # default
        if self == Environment.PRIVNET:
            env = "PRIVNET"
        elif self == Environment.TESTNET:
            env = "TESTNET"
        elif self == Environment.MAINNET:
            env = "MAINNET"

        return EnvironmentConfig(
            algod_address=environ[f"{env}_ALGOD_ADDRESS"],
            algod_token=environ[f"{env}_ALGOD_TOKEN"],
            kmd_address=environ[f"{env}_KMD_ADDRESS"],
            kmd_token=environ[f"{env}_KMD_TOKEN"],
            indexer_address=environ[f"{env}_INDEXER_ADDRESS"],
        )

    def _get_env(self):
        return self.config_from_env()

    def make_algod_client(self):
        env = self._get_env()
        return algod.AlgodClient(env.algod_token, env.algod_address)

    def make_indexer_client(self, token: Optional[str] = None):
        if token is None:
            token = ""
        env = self._get_env()
        return indexer.IndexerClient(token, env.indexer_address)

    def make_kmd_client(self):
        env = self._get_env()
        return kmd.KMDClient(env.kmd_token, env.kmd_address)


def get_balance(address: str):
    return algod_client.account_info(address)["amount"]


# from: https://pyteal.readthedocs.io/en/stable/examples.html
def wait_for_confirmation(client, txid):
    last_round = client.status().get("last-round")
    txinfo = client.pending_transaction_info(txid)
    while not (txinfo.get("confirmed-round") and txinfo.get("confirmed-round") > 0):
        print("Waiting for confirmation...")
        last_round += 1
        client.status_after_block(last_round)
        txinfo = client.pending_transaction_info(txid)
    print(
        "Transaction {} confirmed in round {}.".format(
            txid, txinfo.get("confirmed-round")
        )
    )
    return txinfo


def print_status(title: str):
    print(title)
    print("-" * 80)
    msg = f"""\
alice:
  address: {alice[:5]}...{alice[-5:]}
  balance: {get_balance(alice)}

bob:
  address: {bob[:5]}...{bob[-5:]}
  balance: {get_balance(bob)}

contract:
  address: {contract[:5]}...{contract[-5:]}
  balance: {get_balance(contract)}
"""
    print(msg, end="")
    print("-" * 80, end="\n\n")


def generate_pyteal():
    return And(
        Txn.fee() <= Int(10_000),
        Len(Arg(0)) == Int(73),
        Sha256(Arg(0))
        == Bytes("base64", "30AT2gOReDBdJmLBO/DgvjC6hIXgACecTpFDcP1bJHU="),
        Txn.close_remainder_to() == Txn.receiver(),
    )


if __name__ == "__main__":
    # make clients
    algod_client = Environment.SANDBOX.make_algod_client()
    indexer_client = Environment.SANDBOX.make_indexer_client()
    kmd_client = Environment.SANDBOX.make_kmd_client()

    # get secret from env
    passphrase = environ.get("PASSPHRASE")

    # get handle to wallet for signing later
    wallets = kmd_client.list_wallets()
    default_wallet = wallets[0]
    wallet_handle = kmd_client.init_wallet_handle(default_wallet["id"], "")

    # get account addresses from algod genesis.json
    alice = environ["ALICE_ADDRESS"]
    bob = environ["BOB_ADDRESS"]

    # create contract
    teal_source = compileTeal(generate_pyteal(), mode=Mode.Signature, version=2)
    compilation_result = algod_client.compile(teal_source)
    contract = compilation_result["hash"]
    contract_bytes = base64.b64decode(compilation_result["result"])

    print_status(title="starting balances")

    # alice funds contract
    params = algod_client.suggested_params()
    txn = PaymentTxn(amt=1_000_000, sender=alice, sp=params, receiver=contract)
    signed_txn = kmd_client.sign_transaction(wallet_handle, "", txn)
    txn_id = algod_client.send_transaction(signed_txn)

    wait_for_confirmation(algod_client, txn_id)
    print()

    print_status(title="balances after contract funded")

    # create lsig and close contract
    lsig = LogicSigAccount(
        program=contract_bytes,
        args=[bytes(passphrase, encoding="utf8")],
    )

    params = algod_client.suggested_params()
    txn = PaymentTxn(
        amt=0, sender=contract, sp=params, receiver=bob, close_remainder_to=bob
    )

    lsig_txn = LogicSigTransaction(transaction=txn, lsig=lsig)
    txn_id = algod_client.send_transaction(lsig_txn)

    wait_for_confirmation(algod_client, txn_id)
    print()

    print_status(title="balances after contract is closed")
