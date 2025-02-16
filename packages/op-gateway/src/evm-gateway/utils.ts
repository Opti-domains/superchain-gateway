import { AbiCoder } from "ethers";
import { type StateProof } from "./EVMProofHelper.js";

const flatten = (data: string) => {
  return AbiCoder.defaultAbiCoder().encode(["bytes[]"], [data]);
};

export const convertIntoMerkleTrieProof = (proof: StateProof) => {
  return {
    stateTrieWitness: flatten(proof.stateTrieWitness),
    storageProofs: proof.storageProofs.map(flatten),
  };
};
