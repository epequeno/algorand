# stdlib
from dataclasses import dataclass
from enum import Enum, auto
from os import environ
import json

# 3rd party
import pyteal
from algosdk.v2client import algod

# local


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

    def make_algod_client(self):
        env = self.config_from_env()
        return algod.AlgodClient(env.algod_token, env.algod_address)


@dataclass
class EnvironmentConfig:
    algod_address: str
    algod_token: str
    kmd_address: str
    kmd_token: str
    indexer_address: str


def main():
    algod_client = Environment.SANDBOX.make_algod_client()
    print(json.dumps(algod_client.status()))


if __name__ == "__main__":
    main()
