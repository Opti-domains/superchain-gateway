// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IFaultDisputeGame } from "./IFaultDisputeGame.sol";
import { IDisputeGameFactory } from "./IDisputeGameFactory.sol";
import { ISuperchainConfig } from "../lib/ISuperchainConfig.sol";
import { GameType, Hash, OutputRoot } from "../lib/Types.sol";

interface IAnchorStateRegistry {
    struct StartingAnchorRoot {
        GameType gameType;
        OutputRoot outputRoot;
    }

    error InvalidGameStatus();
    error Unauthorized();
    error UnregisteredGame();

    event Initialized(uint8 version);

    function anchors(GameType) external view returns (Hash root, uint256 l2BlockNumber); // nosemgrep
    function disputeGameFactory() external view returns (IDisputeGameFactory);
    function initialize(
        StartingAnchorRoot[] memory _startingAnchorRoots,
        ISuperchainConfig _superchainConfig
    )
        external;
    function setAnchorState(IFaultDisputeGame _game) external;
    function superchainConfig() external view returns (ISuperchainConfig);
    function tryUpdateAnchorState() external;
    function version() external view returns (string memory);

    function __constructor__(IDisputeGameFactory _disputeGameFactory) external;
}