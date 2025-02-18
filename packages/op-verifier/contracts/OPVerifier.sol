// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IEVMVerifier} from "@optidomains/evm-verifier/contracts/IEVMVerifier.sol";
import {StateProof, EVMProofHelper} from "@optidomains/evm-verifier/contracts/EVMProofHelper.sol";
import {DisputeGameLookup, L2OutputOracleLookup, IOptimismPortalOutputRoot, OPWitnessProofType} from "./lib/OPOutputLookup.sol";
import {MerkleTrieProofHelper} from "@optidomains/evm-verifier/contracts/MerkleTrieProofHelper.sol";
import {Hashing} from "src/libraries/Hashing.sol";
import {Types} from "src/libraries/Types.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

struct OPWitnessData {
    OPWitnessProofType proofType;
    uint256 index;
    Types.OutputRootProof outputRootProof;
}

contract OPVerifier is IEVMVerifier, Initializable {
    using Strings for address;
    using Strings for uint256;

    error OutputRootMismatch(
        OPWitnessProofType proofType,
        uint256 index,
        bytes32 expected,
        bytes32 actual
    );

    uint256 public immutable maxAge;

    string[] _gatewayURLs;

    constructor(uint256 maximumAge) {
        maxAge = maximumAge;
    }

    function initialize(string[] memory urls) external initializer {
        _gatewayURLs = urls;
    }

    function gatewayURLs(
        bytes memory verifierData
    ) external view returns (string[] memory) {
        (address optimismPortalAddress, uint256 minAge) = abi.decode(
            verifierData,
            (address, uint256)
        );

        uint256 gatewayURLsLength = _gatewayURLs.length;
        string[] memory urls = new string[](gatewayURLsLength);

        unchecked {
            for (uint256 i = 0; i < gatewayURLsLength; i++) {
                urls[i] = string.concat(
                    _gatewayURLs[i],
                    "/",
                    optimismPortalAddress.toHexString(),
                    "/",
                    minAge.toString(),
                    "/{sender}/{data}.json"
                );
            }
        }

        return urls;
    }

    function getL2OracleOutput(
        uint256 index,
        IOptimismPortalOutputRoot optimismPortal,
        uint256 minAge
    ) internal view returns (bytes32) {
        return
            L2OutputOracleLookup
                .getL2Output(optimismPortal, index, minAge, maxAge)
                .outputRoot;
    }

    function getDisputeGameOutput(
        uint256 index,
        IOptimismPortalOutputRoot optimismPortal,
        uint256 minAge
    ) internal view returns (bytes32) {
        (bytes32 outputRoot, , , ) = DisputeGameLookup.getRespectedDisputeGame(
            optimismPortal,
            index,
            minAge,
            maxAge
        );

        return outputRoot;
    }

    function getStorageValues(
        address target,
        bytes32[] memory commands,
        bytes[] memory constants,
        bytes memory proof,
        bytes memory verifierData
    ) external view returns (bytes[] memory values) {
        (address optimismPortalAddress, uint256 minAge) = abi.decode(
            verifierData,
            (address, uint256)
        );
        (OPWitnessData memory opData, StateProof memory stateProof) = abi
            .decode(proof, (OPWitnessData, StateProof));
        bytes32 expectedRoot = Hashing.hashOutputRootProof(
            opData.outputRootProof
        );

        bytes32 outputRoot;

        if (opData.proofType == OPWitnessProofType.DisputeGame) {
            outputRoot = getDisputeGameOutput(
                opData.index,
                IOptimismPortalOutputRoot(optimismPortalAddress),
                minAge
            );
        } else if (opData.proofType == OPWitnessProofType.L2OutputOracle) {
            outputRoot = getL2OracleOutput(
                opData.index,
                IOptimismPortalOutputRoot(optimismPortalAddress),
                minAge
            );
        }

        if (outputRoot != expectedRoot) {
            revert OutputRootMismatch(
                opData.proofType,
                opData.index,
                expectedRoot,
                outputRoot
            );
        }

        bytes32 storageRoot = MerkleTrieProofHelper.getStorageRoot(
            opData.outputRootProof.stateRoot,
            target,
            stateProof.stateTrieWitness
        );
        return
            EVMProofHelper.getStorageValues(
                target,
                MerkleTrieProofHelper.getTrieProof,
                commands,
                constants,
                storageRoot,
                stateProof.storageProofs
            );
    }
}
