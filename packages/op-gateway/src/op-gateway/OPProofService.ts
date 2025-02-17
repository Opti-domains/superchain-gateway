import {
  EVMProofHelper,
  convertIntoMerkleTrieProof,
  type IProofService,
} from "../evm-gateway";
import { type JsonRpcBlock } from "@ethereumjs/block";
import {
  AbiCoder,
  Contract,
  FallbackProvider,
  getAddress,
  JsonRpcProvider,
  type AddressLike,
} from "ethers";
import OPOutputLookupABI from "./OPOutputLookup.js";
import RPC from "../rpc.json";

export class InvalidOptimismPortalError extends Error {
  constructor() {
    super("OptimismPortal is invalid");
  }
}

export class DisputeGameChallengedError extends Error {
  constructor() {
    super("Dispute game is challenged");
  }
}

export enum OPWitnessProofType {
  L2OutputOracle = 0,
  DisputeGame = 1,
}

export interface OPProvableBlock {
  number: number;
  proofType: OPWitnessProofType;
  index: number;
  optimismPortalAddress: string;
}

// OPOutputLookup contract is deployed with deterministic deployment
// As a result, OPOutputLookup is always deployed to the same address
// See OPOutputLookup.sol on op-verifier/contracts/OPOutputLookup.sol
const OP_OUTPUT_LOOKUP = "0x475dc200b71dbd9776518C299e281766FaDf4A30";

const L2_TO_L1_MESSAGE_PASSER_ADDRESS =
  "0x4200000000000000000000000000000000000016";

const L2_PROVIDERS: {
  [address: string]: {
    provider: JsonRpcProvider;
    helper: EVMProofHelper;
  };
} = {};

/**
 * The proofService class can be used to calculate proofs for a given target and slot on the Optimism Bedrock network.
 * It's also capable of proofing long types such as mappings or string by using all included slots in the proof.
 *
 */
export class OPProofService implements IProofService<OPProvableBlock> {
  private readonly l1Provider: FallbackProvider;
  private opOutputLookup: Contract;

  constructor(l1Provider: JsonRpcProvider[]) {
    this.l1Provider = new FallbackProvider(
      l1Provider.map((p, i) => ({
        provider: p,
        priority: l1Provider.length - i,
        weight: l1Provider.length - i,
        stallTimeout: 2000,
      }))
    );

    this.opOutputLookup = new Contract(
      OP_OUTPUT_LOOKUP,
      OPOutputLookupABI,
      this.l1Provider
    );
  }

  getProvider(optimismPortalAddress: string): {
    provider: JsonRpcProvider;
    helper: EVMProofHelper;
  } {
    optimismPortalAddress = getAddress(optimismPortalAddress);

    if (L2_PROVIDERS[optimismPortalAddress]) {
      return L2_PROVIDERS[optimismPortalAddress];
    }

    const rpc =
      process.env[`RPC_${optimismPortalAddress}`] ||
      RPC[optimismPortalAddress as keyof typeof RPC];

    if (!rpc) {
      throw new Error("This optimism portal is not in the superchain registry");
    }

    const provider = new JsonRpcProvider(rpc);
    const helper = new EVMProofHelper(provider);

    L2_PROVIDERS[optimismPortalAddress] = { provider, helper };
    return { provider, helper };
  }

  /**
   * @dev Returns an object representing a block whose state can be proven on L1.
   */
  async getProvableBlock(
    optimismPortalAddress: string,
    minAge: number
  ): Promise<OPProvableBlock> {
    console.log("optimismPortalAddress", optimismPortalAddress);

    const block = await this.opOutputLookup.getOPProvableBlock(
      optimismPortalAddress,
      minAge,
      1296000 // 15 days
    );

    console.log(block);

    return {
      number: block.blockNumber,
      proofType: block.proofType,
      index: block.index,
      optimismPortalAddress: optimismPortalAddress,
    };
  }

  /**
   * @dev Returns the value of a contract state slot at the specified block
   * @param block A `ProvableBlock` returned by `getProvableBlock`.
   * @param address The address of the contract to fetch data from.
   * @param slot The slot to fetch.
   * @returns The value in `slot` of `address` at block `block`
   */
  getStorageAt(
    block: OPProvableBlock,
    address: AddressLike,
    slot: bigint
  ): Promise<string> {
    const { helper } = this.getProvider(block.optimismPortalAddress);
    return helper.getStorageAt(block.number, address, slot);
  }

  /**
   * @dev Fetches a set of proofs for the requested state slots.
   * @param block A `ProvableBlock` returned by `getProvableBlock`.
   * @param address The address of the contract to fetch data from.
   * @param slots An array of slots to fetch data for.
   * @returns A proof of the given slots, encoded in a manner that this service's
   *   corresponding decoding library will understand.
   */
  async getProofs(
    block: OPProvableBlock,
    address: AddressLike,
    slots: bigint[]
  ): Promise<string> {
    const { helper, provider } = this.getProvider(block.optimismPortalAddress);
    const proof = await helper.getProofs(block.number, address, slots);
    const rpcBlock: JsonRpcBlock = await provider.send("eth_getBlockByNumber", [
      "0x" + block.number.toString(16),
      false,
    ]);
    const messagePasserStorageRoot = await this.getMessagePasserStorageRoot(
      helper,
      block.number
    );

    return AbiCoder.defaultAbiCoder().encode(
      [
        "tuple(uint8 proofType, uint256 index, tuple(bytes32 version, bytes32 stateRoot, bytes32 messagePasserStorageRoot, bytes32 latestBlockhash) outputRootProof)",
        "tuple(bytes stateTrieWitness, bytes[] storageProofs)",
      ],
      [
        {
          blockNo: block.number,
          proofType: block.proofType,
          index: block.index,
          outputRootProof: {
            version:
              "0x0000000000000000000000000000000000000000000000000000000000000000",
            stateRoot: rpcBlock.stateRoot,
            messagePasserStorageRoot,
            latestBlockhash: rpcBlock.hash,
          },
        },
        convertIntoMerkleTrieProof(proof),
      ]
    );
  }

  private async getMessagePasserStorageRoot(
    helper: EVMProofHelper,
    blockNo: number
  ) {
    const { stateRoot } = await helper.getProofs(
      blockNo,
      L2_TO_L1_MESSAGE_PASSER_ADDRESS,
      []
    );
    return stateRoot;
  }
}
