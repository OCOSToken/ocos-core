// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SettlementEngine is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant SETTLEMENT_ADMIN_ROLE = keccak256("SETTLEMENT_ADMIN_ROLE");
    bytes32 public constant SETTLEMENT_OPERATOR_ROLE = keccak256("SETTLEMENT_OPERATOR_ROLE");

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

    uint256 public totalSettlements;

    mapping(uint256 => SettlementRequest) private settlements;

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

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SETTLEMENT_ADMIN_ROLE, admin);
        _grantRole(SETTLEMENT_OPERATOR_ROLE, admin);
    }

    function createSettlement(
        uint256 sourceNetworkId,
        uint256 destinationNetworkId,
        address asset,
        uint256 amount,
        bytes32 destinationAccountHash,
        bytes32 referenceHash
    ) external nonReentrant whenNotPaused returns (uint256 settlementId) {
        require(sourceNetworkId != 0, "Invalid source network");
        require(destinationNetworkId != 0, "Invalid destination network");
        require(amount > 0, "Invalid amount");
        require(destinationAccountHash != bytes32(0), "Invalid destination");
        require(referenceHash != bytes32(0), "Invalid reference");

        settlementId = ++totalSettlements;

        settlements[settlementId] = SettlementRequest({
            id: settlementId,
            sourceNetworkId: sourceNetworkId,
            destinationNetworkId: destinationNetworkId,
            requester: msg.sender,
            asset: asset,
            amount: amount,
            destinationAccountHash: destinationAccountHash,
            referenceHash: referenceHash,
            status: SettlementStatus.Pending,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        emit SettlementCreated(
            settlementId,
            sourceNetworkId,
            destinationNetworkId,
            msg.sender,
            asset,
            amount,
            destinationAccountHash,
            referenceHash
        );
    }

    function updateSettlementStatus(
        uint256 settlementId,
        SettlementStatus newStatus,
        bytes32 referenceHash
    ) external whenNotPaused onlyRole(SETTLEMENT_OPERATOR_ROLE) {
        SettlementRequest storage settlement = settlements[settlementId];

        require(settlement.id != 0, "Settlement not found");
        require(referenceHash != bytes32(0), "Invalid reference");
        require(!_isFinalStatus(settlement.status), "Already finalized");

        SettlementStatus oldStatus = settlement.status;
        settlement.status = newStatus;
        settlement.referenceHash = referenceHash;
        settlement.updatedAt = block.timestamp;

        emit SettlementStatusUpdated(settlementId, oldStatus, newStatus, referenceHash);
    }

    function getSettlement(uint256 settlementId) external view returns (SettlementRequest memory) {
        require(settlements[settlementId].id != 0, "Settlement not found");
        return settlements[settlementId];
    }

    function _isFinalStatus(SettlementStatus status) internal pure returns (bool) {
        return (
            status == SettlementStatus.Completed ||
            status == SettlementStatus.Failed ||
            status == SettlementStatus.Cancelled
        );
    }

    function pause() external onlyRole(SETTLEMENT_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(SETTLEMENT_ADMIN_ROLE) {
        _unpause();
    }
}
