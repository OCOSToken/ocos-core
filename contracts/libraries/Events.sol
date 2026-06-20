// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library Events {

    event ReserveAllocated(
        uint256 indexed networkId,
        uint256 amount
    );

    event ReserveReleased(
        uint256 indexed networkId,
        uint256 amount
    );

    event RouterActivated(
        uint256 indexed networkId
    );

    event RouterDisabled(
        uint256 indexed networkId
    );

    event SettlementCreated(
        uint256 indexed settlementId
    );

    event SettlementCompleted(
        uint256 indexed settlementId
    );

    event SettlementFailed(
        uint256 indexed settlementId
    );

    event LiquidityAllocated(
        address indexed token,
        uint256 amount
    );

    event LiquidityReleased(
        address indexed token,
        uint256 amount
    );

    event EmergencyTriggered(
        address indexed operator
    );

    event EmergencyResolved(
        address indexed operator
    );
}
