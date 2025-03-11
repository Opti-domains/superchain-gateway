# OP Verifier

A verifier contract that verifies proofs from the OP CCIP gateway.

## Build

```bash
pnpm build
```

## Deployment

The OP Verifier is deployed to the same address across chains:
- Ethereum Mainnet: [0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa](https://etherscan.io/address/0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa)
- Ethereum Sepolia: [0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa](https://sepolia.etherscan.io/address/0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa)

To deploy in a new chain, run:

```shell
npx hardhat ignition deploy ./ignition/modules/OPVerifier.ts --network sepolia --strategy create2 --verify
```
