# smart contracts

experiments with smart contracts

# Debugging

get an overview of accounts and current balances without pending rewards from the indexer:

```bash
$ curl -s "localhost:8980/v2/accounts?pretty" | jq '.accounts[]|{address: .address, balance: ."amount-without-pending-rewards"}'
```