# Superchain ENS Gateway

Superchain ENS Gateway is a CCIP gateway connecting domain name on the Superchain to ENS on Ethereum.

## Packages

- [evm-verifier](./packages/evm-verifier): A library for building L2 proof fetching requests, verifying proofs and retrieving values.
- [op-gateway](./packages/op-gateway): A CCIP gateway connecting ENS names on the Superchain to ENS on Ethereum.
- [op-verifier](./packages/op-verifier): A verifier contract that verifies proofs from the OP CCIP gateway.
- [opti-l1-resolver](./packages/opti-l1-resolver): A resolver contract that resolves ENS names on the Superchain through the CCIP gateway.

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
