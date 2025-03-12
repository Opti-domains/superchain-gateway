# Superchain ENS Gateway

Superchain ENS Gateway is a CCIP gateway connecting domain name on the Superchain to ENS on Ethereum.

## Packages

- [evm-verifier](./packages/evm-verifier): A library for building L2 proof fetching requests, verifying proofs and retrieving values.
- [op-gateway](./packages/op-gateway): A CCIP gateway connecting ENS names on the Superchain to ENS on Ethereum.
- [op-verifier](./packages/op-verifier): A verifier contract that verifies proofs from the OP CCIP gateway.
- [opti-l1-resolver](./packages/opti-l1-resolver): A resolver contract that resolves ENS names on the Superchain through the CCIP gateway.

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
