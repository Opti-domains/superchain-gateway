// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EVMFetcher} from "@optidomains/evm-verifier/contracts/EVMFetcher.sol";
import {EVMFetchTarget} from "@optidomains/evm-verifier/contracts/EVMFetchTarget.sol";
import {IEVMVerifier} from "@optidomains/evm-verifier/contracts/IEVMVerifier.sol";

contract TestL1 is EVMFetchTarget {
    using EVMFetcher for EVMFetcher.EVMFetchRequest;

    IEVMVerifier verifier; // Slot 0
    address target;
    address optimismPortalAddress;
    uint256 minAge;

    constructor(
        IEVMVerifier _verifier,
        address _target,
        address _optimismPortalAddress,
        uint256 _minAge
    ) {
        verifier = _verifier;
        target = _target;
        optimismPortalAddress = _optimismPortalAddress;
        minAge = _minAge;
    }

    function getVerifierData() public view returns (bytes memory) {
        return abi.encode(optimismPortalAddress, minAge);
    }

    function getLatest() public view returns (uint256) {
        EVMFetcher.newFetchRequest(verifier, target).getStatic(0).fetch(
            this.getLatestCallback.selector,
            "",
            getVerifierData()
        );
    }

    function getLatestCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (uint256) {
        return abi.decode(values[0], (uint256));
    }

    function getName() public view returns (string memory) {
        EVMFetcher.newFetchRequest(verifier, target).getDynamic(1).fetch(
            this.getNameCallback.selector,
            "",
            getVerifierData()
        );
    }

    function getNameCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[0]);
    }

    function getHighscorer(uint256 idx) public view returns (string memory) {
        EVMFetcher
            .newFetchRequest(verifier, target)
            .getDynamic(3)
            .element(idx)
            .fetch(this.getHighscorerCallback.selector, "", getVerifierData());
    }

    function getHighscorerCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[0]);
    }

    function getLatestHighscore() public view returns (uint256) {
        EVMFetcher
            .newFetchRequest(verifier, target)
            .getStatic(0)
            .getStatic(2)
            .ref(0)
            .fetch(
                this.getLatestHighscoreCallback.selector,
                "",
                getVerifierData()
            );
    }

    function getLatestHighscoreCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (uint256) {
        return abi.decode(values[1], (uint256));
    }

    function getLatestHighscorer() public view returns (string memory) {
        EVMFetcher
            .newFetchRequest(verifier, target)
            .getStatic(0)
            .getDynamic(3)
            .ref(0)
            .fetch(
                this.getLatestHighscorerCallback.selector,
                "",
                getVerifierData()
            );
    }

    function getLatestHighscorerCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[1]);
    }

    function getNickname(
        string memory _name
    ) public view returns (string memory) {
        EVMFetcher
            .newFetchRequest(verifier, target)
            .getDynamic(4)
            .element(_name)
            .fetch(this.getNicknameCallback.selector, "", getVerifierData());
    }

    function getNicknameCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[0]);
    }

    function getPrimaryNickname() public view returns (string memory) {
        EVMFetcher
            .newFetchRequest(verifier, target)
            .getDynamic(1)
            .getDynamic(4)
            .ref(0)
            .fetch(
                this.getPrimaryNicknameCallback.selector,
                "",
                getVerifierData()
            );
    }

    function getPrimaryNicknameCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[1]);
    }

    function getZero() public view returns (uint256) {
        EVMFetcher.newFetchRequest(verifier, target).getStatic(5).fetch(
            this.getZeroCallback.selector,
            "",
            getVerifierData()
        );
    }

    function getZeroCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (uint256) {
        return abi.decode(values[0], (uint256));
    }
}
