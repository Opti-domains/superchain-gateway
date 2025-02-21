// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EVMFetcher} from "@optidomains/evm-verifier/contracts/EVMFetcher.sol";
import {EVMFetchTarget} from "@optidomains/evm-verifier/contracts/EVMFetchTarget.sol";
import {IEVMVerifier} from "@optidomains/evm-verifier/contracts/IEVMVerifier.sol";

// Interface for ENS Registry
interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);
}

// Interface for Name Wrapper
interface INameWrapper {
    function ownerOf(uint256 id) external view returns (address);
}

contract SingularL1Resolver is EVMFetchTarget {
    using EVMFetcher for EVMFetcher.EVMFetchRequest;

    struct VerifierConfig {
        IEVMVerifier verifier;
        address resolver;
        bytes verifierData;
    }

    VerifierConfig public defaultVerifierConfig;
    mapping(bytes32 => VerifierConfig) public verifierConfigs;

    // Immutable ENS contracts
    IENSRegistry public immutable registry;
    INameWrapper public nameWrapper;

    constructor(IENSRegistry _registry) {
        registry = _registry;
    }

    /**
     * @dev Returns true if the caller is authorized for the given node
     * @param node The node to check authorization for
     */
    function isAuthorized(bytes32 node) internal view returns (bool) {
        address owner = registry.owner(node);
        if (
            owner == address(nameWrapper) && address(nameWrapper) != address(0)
        ) {
            // If owned by wrapper, check wrapper owner
            return nameWrapper.ownerOf(uint256(node)) == msg.sender;
        }
        // Otherwise check registry owner
        return owner == msg.sender;
    }

    /**
     * @dev Modifier to check if caller is authorized for a node
     * @param node The node to check authorization for
     */
    modifier authorized(bytes32 node) {
        require(isAuthorized(node), "Not authorized");
        _;
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "opverifier.admin" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function owner() public view returns (address) {
        bytes32 slot = ADMIN_SLOT;
        address _owner;
        assembly {
            _owner := sload(slot)
        }
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Caller is not the owner");
        _;
    }

    function setDefaultVerifierConfig(
        INameWrapper _nameWrapper,
        VerifierConfig calldata _config
    ) public onlyOwner {
        nameWrapper = _nameWrapper;
        defaultVerifierConfig = _config;
    }

    function setVerifierConfig(
        bytes32 node,
        VerifierConfig calldata _config
    ) public authorized(node) {
        verifierConfigs[node] = _config;
    }

    function getVerifierConfig(
        bytes32 node
    ) public view returns (VerifierConfig memory) {
        VerifierConfig memory config = verifierConfigs[node];
        if (address(config.verifier) == address(0)) {
            return defaultVerifierConfig;
        }
        return config;
    }

    function addr(
        bytes32 node,
        uint256 cointype
    ) public view returns (address) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getStatic(0)
            .element(node)
            .element(cointype)
            .fetch(
                this.addrCallback.selector,
                abi.encode(node),
                config.verifierData
            );
    }

    function addr(bytes32 node) public view returns (address) {
        return addr(node, 60);
    }

    function addrCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (address) {
        return abi.decode(values[0], (address));
    }

    function text(
        bytes32 node,
        string calldata key
    ) public view returns (string memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(1)
            .element(node)
            .element(key)
            .fetch(
                this.textCallback.selector,
                abi.encode(node, key),
                config.verifierData
            );
    }

    function textCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (string memory) {
        return string(values[0]);
    }

    function getData(
        bytes32 node,
        string calldata key
    ) public view returns (bytes memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(2)
            .element(node)
            .element(key)
            .fetch(
                this.getDataCallback.selector,
                abi.encode(node, key),
                config.verifierData
            );
    }

    function getDataCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (bytes memory) {
        return values[0];
    }

    function contenthash(bytes32 node) public view returns (bytes memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(3)
            .element(node)
            .fetch(
                this.contenthashCallback.selector,
                abi.encode(node),
                config.verifierData
            );
    }

    function contenthashCallback(
        bytes[] memory values,
        bytes memory
    ) public pure returns (bytes memory) {
        return values[0];
    }

    function resolve(
        bytes memory /* name */,
        bytes memory data
    ) external view returns (bytes memory) {
        (bool success, bytes memory result) = address(this).staticcall(data);
        if (success) {
            return result;
        } else {
            // Revert with the reason provided by the call
            assembly {
                revert(add(result, 0x20), mload(result))
            }
        }
    }
}
