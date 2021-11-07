"""
pyteal/algosdk implementation of https://developer.algorand.org/tutorials/writing-simple-smart-contract/
"""
# stdlib
from dataclasses import dataclass
from enum import Enum, auto
from os import environ
from typing import Optional
import base64
from contextlib import contextmanager

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
        env_name = "SANDBOX"  # default
        if self == Environment.PRIVNET:
            env_name = "PRIVNET"
        elif self == Environment.TESTNET:
            env_name = "TESTNET"
        elif self == Environment.MAINNET:
            env_name = "MAINNET"

        return EnvironmentConfig(
            algod_address=environ[f"{env_name}_ALGOD_ADDRESS"],
            algod_token=environ[f"{env_name}_ALGOD_TOKEN"],
            kmd_address=environ[f"{env_name}_KMD_ADDRESS"],
            kmd_token=environ[f"{env_name}_KMD_TOKEN"],
            indexer_address=environ[f"{env_name}_INDEXER_ADDRESS"],
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


@dataclass
class WalletHandle:
    client: kmd.KMDClient
    wallet_id: str
    wallet_password: str
    _token: Optional[str] = None

    @staticmethod
    def new(client: kmd.KMDClient, wallet_id: str, wallet_password: str):
        print("initiating handle")
        tok = client.init_wallet_handle(wallet_id, wallet_password)
        return WalletHandle(
            client=client,
            wallet_id=wallet_id,
            wallet_password=wallet_password,
            _token=tok,
        )

    @property
    def token(self):
        try:
            self.client.get_wallet(self._token)
        except:
            new_tok = self.client.init_wallet_handle(
                self.wallet_id, self.wallet_password
            )
            self._token = new_tok

        return self._token

    def release(self):
        print("releasing handle")
        self.client.release_wallet_handle(self.token)


@contextmanager
def handle(*args, **kwargs):
    handler = args[0]
    try:
        yield handler
    finally:
        handler.release()


def approval():
    return And(
        Txn.fee() <= Int(10_000),
        Len(Arg(0)) == Int(73),
        Sha256(Arg(0))
        == Bytes("base64", "30AT2gOReDBdJmLBO/DgvjC6hIXgACecTpFDcP1bJHU="),
        Txn.close_remainder_to() == Txn.receiver(),
    )


if __name__ == "__main__":
    # make clients
    environment = Environment.SANDBOX
    algod_client = environment.make_algod_client()
    indexer_client = environment.make_indexer_client()
    kmd_client = environment.make_kmd_client()

    # helper alias
    sp = algod_client.suggested_params

    # get secret from env
    passphrase = environ.get("PASSPHRASE")

    # get account addresses from algod genesis.json
    alice = environ["ALICE_ADDRESS"]
    bob = environ["BOB_ADDRESS"]

    # create contract
    teal_source = compileTeal(approval(), mode=Mode.Signature, version=2)
    compilation_result = algod_client.compile(teal_source)
    contract = compilation_result["hash"]
    contract_bytes = base64.b64decode(compilation_result["result"])

    print_status(title="starting balances")

    # alice funds contract
    txn = PaymentTxn(amt=1_000_000, sender=alice, sp=sp(), receiver=contract)

    # get handle to wallet for signing later
    wallets = kmd_client.list_wallets()
    wallet_id = wallets[0]["id"]
    wh = WalletHandle.new(client=kmd_client, wallet_id=wallet_id, wallet_password="")
    with handle(wh) as h:
        signed_txn = kmd_client.sign_transaction(h.token, h.wallet_password, txn)

    txn_id = algod_client.send_transaction(signed_txn)

    wait_for_confirmation(algod_client, txn_id)
    print()

    print_status(title="balances after contract funded")

    # create lsig and close contract
    lsig = LogicSigAccount(
        program=contract_bytes,
        args=[bytes(passphrase, encoding="utf8")],
    )

    txn = PaymentTxn(
        amt=0, sender=contract, sp=sp(), receiver=bob, close_remainder_to=bob
    )

    lsig_txn = LogicSigTransaction(transaction=txn, lsig=lsig)
    txn_id = algod_client.send_transaction(lsig_txn)

    wait_for_confirmation(algod_client, txn_id)
    print()

    print_status(title="balances after contract is closed")
