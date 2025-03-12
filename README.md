# Superchain ENS Gateway

Superchain ENS Gateway is a CCIP gateway connecting domain name on the Superchain to ENS on Ethereum.

## Packages

- [evm-verifier](./packages/evm-verifier): A library for building L2 proof fetching requests, verifying proofs and retrieving values.
- [op-gateway](./packages/op-gateway): A CCIP gateway connecting ENS names on the Superchain to ENS on Ethereum.
- [op-verifier](./packages/op-verifier): A verifier contract that verifies proofs from the OP CCIP gateway.
- [opti-l1-resolver](./packages/opti-l1-resolver): A resolver contract that resolves ENS names on the Superchain through the CCIP gateway.

## Deployments

### Opti L1 Resolver

Unlike other solutions that require you to develop your own gateway on the ETH mainnet, our approach is designed for ease of use: simply set your ENS mainnet resolver to our Superchain Resolver and point it to your SingularResolver deployment with a single transaction.

- Ethereum Mainnet: [0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72](https://etherscan.io/address/0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72)
- Ethereum Sepolia: [0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72](https://sepolia.etherscan.io/address/0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72)

### OP Verifier

Verifier contract for implementing L1 resolver

- Ethereum Mainnet: [0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa](https://etherscan.io/address/0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa)
- Ethereum Sepolia: [0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa](https://sepolia.etherscan.io/address/0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa)

### Gateway

Opti.Domains CCIP Gateway for resolving domain records on Superchain

- Mainnet: https://gateway.opti.domains
- Sepolia Testnet: https://gateway-sepolia.opti.domains

## How our CCIP Gateway is Novel

Our CCIP Gateway is innovative because it automatically handles the L2OutputOracle migration to DisputeGame and adjusts to dispute game type changes without needing to deploy a new gateway and verifier smart contract, ensuring zero downtime during this major migration.

Moreover, a single instance of our gateway and verifier contract can manage an indefinite number of Superchain registrations in the Superchain registry without requiring separate deployments for each chain.

Here is a comparison with current Unruggable OP Gateway implementation:

| Feature                                                                                  | Unruggable | Opti.Domains |
|------------------------------------------------------------------------------------------|------------|--------------|
| Automatically handles the L2OutputOracle to DisputeGame migration              | ❌         | ✅           |
| Support any Superchain with a single instance of gateway and verifier contract deployment | ❌         | ✅           |
| Support complex L2 data fetching operations                                               | ✅         | ❌           |

## Getting Started

1. Clone the repository.
2. Install necessary dependencies.

```bash
pnpm install
```

3. Build packages.

```bash
pnpm build
```

4. Read the readme of each package for more information.
