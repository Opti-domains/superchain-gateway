# Opti L1 Resolver

A resolver contract that resolves ENS names on the Superchain through the CCIP gateway.

## Build

```bash
pnpm build
```

## Deployments

L1 Resolver contracts are deployed to the same address across chains:
- Ethereum Mainnet: [0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72](https://etherscan.io/address/0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72)
- Ethereum Sepolia: [0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72](https://sepolia.etherscan.io/address/0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72)

To deploy in a new chain, run:

```shell
npx hardhat ignition deploy ./ignition/modules/SingularL1Resolver.ts --network sepolia --strategy create2 --verify
```
