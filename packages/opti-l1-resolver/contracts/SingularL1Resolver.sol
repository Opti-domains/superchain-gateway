// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EVMFetcher} from "@optidomains/evm-verifier/contracts/EVMFetcher.sol";
import {EVMFetchTarget} from "@optidomains/evm-verifier/contracts/EVMFetchTarget.sol";
import {IEVMVerifier} from "@optidomains/evm-verifier/contracts/IEVMVerifier.sol";
import {IAddrResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddrResolver.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";
import {ITextResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/ITextResolver.sol";
import {IContentHashResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IContentHashResolver.sol";
import {IExtendedResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IExtendedResolver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// Interface for ENS Registry
interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);
}

// Interface for Name Wrapper
interface INameWrapper {
    function ownerOf(uint256 id) external view returns (address);
}

contract SingularL1Resolver is
    EVMFetchTarget,
    IAddrResolver,
    IAddressResolver,
    ITextResolver,
    IContentHashResolver,
    IERC165
{
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
        VerifierConfig memory _config
    ) public onlyOwner {
        nameWrapper = _nameWrapper;
        defaultVerifierConfig = _config;
    }

    function setVerifierConfig(
        bytes32 node,
        VerifierConfig memory _config
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

    function bytesToAddress(
        bytes memory b
    ) internal pure returns (address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addr(
        bytes32 node,
        uint256 cointype
    ) public view returns (bytes memory) {
        return _addr(node, cointype, this.addrCallback.selector);
    }

    function addr(bytes32 node) public view returns (address payable) {
        _addr(node, 60, this.addrEvmCallback.selector);
    }

    function _addr(
        bytes32 node,
        uint256 cointype,
        bytes4 callback
    ) internal view returns (bytes memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(0)
            .element(node)
            .element(cointype)
            .fetch(callback, msg.data[0:4], config.verifierData);
    }

    function addrCallback(
        bytes[] memory values,
        bytes memory sig
    ) public pure returns (bytes memory) {
        if (keccak256(sig) != keccak256(hex"9061b923")) {
            return values[0];
        }
        return abi.encode(values[0]);
    }

    function addrEvmCallback(
        bytes[] memory values,
        bytes memory sig
    ) public pure returns (bytes memory) {
        address result = address(bytes20(values[0]));
        if (keccak256(sig) != keccak256(hex"9061b923")) {
            // Return address instead of bytes
            assembly {
                let freemem := mload(0x40)
                mstore(freemem, result)
                return(freemem, 0x20)
            }
        }
        return abi.encode(result);
    }

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

    function data(
        bytes32 node,
        string calldata key
    ) public view returns (bytes memory) {
        return _data(node, key, this.dataCallback.selector);
    }

    function _data(
        bytes32 node,
        string memory key,
        bytes4 callback
    ) internal view returns (bytes memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(2)
            .element(node)
            .element(key)
            .fetch(callback, msg.data[0:4], config.verifierData);
    }

    function dataCallback(
        bytes[] memory values,
        bytes memory sig
    ) public pure returns (bytes memory) {
        if (keccak256(sig) != keccak256(hex"9061b923")) {
            return values[0];
        }
        return abi.encode(values[0]);
    }

    function contenthash(bytes32 node) public view returns (bytes memory) {
        return _contenthash(node, this.contenthashCallback.selector);
    }

    function _contenthash(
        bytes32 node,
        bytes4 callback
    ) internal view returns (bytes memory) {
        VerifierConfig memory config = getVerifierConfig(node);
        EVMFetcher
            .newFetchRequest(config.verifier, config.resolver)
            .getDynamic(3)
            .element(node)
            .fetch(callback, msg.data[0:4], config.verifierData);
    }

    function contenthashCallback(
        bytes[] memory values,
        bytes memory sig
    ) public pure returns (bytes memory) {
        if (keccak256(sig) != keccak256(hex"9061b923")) {
            return values[0];
        }
        return abi.encode(values[0]);
    }

    function resolve(
        bytes calldata /* name */,
        bytes calldata data
    ) external view returns (bytes memory) {
        bytes4 selector = bytes4(data);

        if (selector == IAddrResolver.addr.selector) {
            bytes32 node = abi.decode(data[4:], (bytes32));
            return _addr(node, 60, this.addrEvmCallback.selector);
        }
        if (selector == IAddressResolver.addr.selector) {
            (bytes32 node, uint256 cointype) = abi.decode(
                data[4:],
                (bytes32, uint256)
            );
            return _addr(node, cointype, this.addrCallback.selector);
        }
        if (selector == ITextResolver.text.selector) {
            (bytes32 node, string memory key) = abi.decode(
                data[4:],
                (bytes32, string)
            );
            return bytes(_text(node, key, this.textCallback.selector));
        }
        if (selector == IContentHashResolver.contenthash.selector) {
            bytes32 node = abi.decode(data[4:], (bytes32));
            return _contenthash(node, this.contenthashCallback.selector);
        }
        if (selector == 0xecbfada3) {
            (bytes32 node, string memory key) = abi.decode(
                data[4:],
                (bytes32, string)
            );
            return bytes(_data(node, key, this.dataCallback.selector));
        }
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public view virtual override returns (bool) {
        return
            interfaceID == type(IAddrResolver).interfaceId ||
            interfaceID == type(IAddressResolver).interfaceId ||
            interfaceID == type(ITextResolver).interfaceId ||
            interfaceID == type(IContentHashResolver).interfaceId ||
            interfaceID == type(IExtendedResolver).interfaceId ||
            interfaceID == type(IERC165).interfaceId;
    }
}
