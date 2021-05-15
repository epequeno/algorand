simple smart contract based on https://developer.algorand.org/tutorials/writing-simple-smart-contract/ 

A key difference is my use of a private network vs. TestNet as suggested in the tutorial.

Implementations are in their own directories:

- `./simple-go`
- `./simple-goal`
- `./simple-rust`

## Contract

This is an escrow style contract which follows this general pattern:
- the contract is created
- the contract account is funded by any number of users (in this example one user provides funds)
- the contract releases all funds to a specified user when provided a password

## Process

![process overview](https://static.swimlanes.io/a8133cad93edd33db7a96f5be0feb669.png) [swimlanes](https://swimlanes.io/#dZBBTgMxDEX3OYWXsGAOMAukgSMA+zGJSyOcOLId5vpkSluJCnZW/PL8bc/ONIPl0pjACqpDlOqK0eGOLKps9yG8GSk8PMLLCXg+A/OoSstMIVRxmsPa0KwdFY0mJ+QVsg3diUmg5F1rrh+AKSmZAdYEm2bf3w6DgVvB5PK5QggL50h/BLgM/ukfek12g/yffel+pOo5ol8X6DvbVL5yIoMNmcmhVCpScwQciaGhYiEnnUIIv537lCd5H2dhMVqK9OqvcnFfz6rENBYcMuZzZpf94zc=)

The `User` in this example is either a person calling the `goal` CLI or a running process from a program using the SDKs.