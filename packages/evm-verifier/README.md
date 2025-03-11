# evm-verifier

A library for building L2 proof fetching requests and verifying proofs.

## Contract inheritance

- Verifier must inherit from `IEVMVerifier` and uses `EVMProofHelper` library to verify proofs and retrieve values.
- L1 Resolver must inherit from `EVMFetchTarget` and uses `EVMFetcher` library to build proof fetching requests.

## Build a proof fetching request

To build a proof fetching request, you need to have both L1 and L2 resolver contract. L1 must build a proof fetching request to fetch corresponding L2 resolver storage slot.

```solidity
function text(
    bytes32 node,
    string calldata key
) public view returns (string memory) {
    return _text(node, key, this.textCallback.selector);
}

function _text(
    bytes32 node,
    string memory key,
    bytes4 callback
) internal view returns (string memory) {
    VerifierConfig memory config = getVerifierConfig(node);
    EVMFetcher
        .newFetchRequest(config.verifier, config.resolver)
        .getDynamic(1)
        .element(node)
        .element(key)
        .fetch(callback, msg.data[0:4], config.verifierData);
}

function textCallback(
    bytes[] memory values,
    bytes memory sig
) public pure returns (bytes memory) {
    if (keccak256(sig) != keccak256(hex"9061b923")) {
        return values[0];
    }
    return abi.encode(values[0]);
}
```

## Verify a proof and retrieve values

```solidity
return EVMProofHelper.getStorageValues(
  target,
  MerkleTrieProofHelper.getTrieProof,
  commands,
  constants,
  storageRoot,
  stateProof.storageProofs
);
```

See a complete example in [OPVerifier.sol](../op-verifier/contracts/OPVerifier.sol).
