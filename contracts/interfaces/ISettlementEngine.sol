// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface ISettlementEngine {
    enum SettlementStatus {
        Pending,
        Executing,
        Completed,
        Failed,
        Cancelled
    }

    struct SettlementRequest {
        uint256 id;
        uint256 sourceNetworkId;
        uint256 destinationNetworkId;
        address requester;
        address asset;
        uint256 amount;
        bytes32 destinationAccountHash;
        bytes32 referenceHash;
        SettlementStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    event SettlementCreated(
        uint256 indexed id,
        uint256 indexed sourceNetworkId,
        uint256 indexed destinationNetworkId,
        address requester,
        address asset,
        uint256 amount,
        bytes32 destinationAccountHash,
        bytes32 referenceHash
    );

    event SettlementStatusUpdated(
        uint256 indexed id,
        SettlementStatus oldStatus,
        SettlementStatus newStatus,
        bytes32 referenceHash
    );

    function createSettlement(
        uint256 sourceNetworkId,
        uint256 destinationNetworkId,
        address asset,
        uint256 amount,
        bytes32 destinationAccountHash,
        bytes32 referenceHash
    ) external returns (uint256 settlementId);

    function updateSettlementStatus(
        uint256 settlementId,
        SettlementStatus newStatus,
        bytes32 referenceHash
    ) external;

    function getSettlement(uint256 settlementId)
        external
        view
        returns (SettlementRequest memory);

    function totalSettlements() external view returns (uint256);
}
