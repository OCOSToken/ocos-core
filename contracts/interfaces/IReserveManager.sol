// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IReserveManager {
    enum ReserveStatus {
        Pending,
        Active,
        Suspended,
        Depleted
    }

    struct NetworkReserve {
        uint256 networkId;
        string networkName;
        uint256 requiredReserve;
        uint256 allocatedReserve;
        ReserveStatus status;
        uint256 updatedAt;
    }

    event NetworkReserveCreated(
        uint256 indexed networkId,
        string networkName,
        uint256 requiredReserve
    );

    event ReserveAllocated(
        uint256 indexed networkId,
        uint256 amount,
        ReserveStatus status
    );

    event ReserveStatusUpdated(
        uint256 indexed networkId,
        ReserveStatus status
    );

    function createNetworkReserve(
        uint256 networkId,
        string calldata networkName,
        uint256 requiredReserve
    ) external;

    function allocateReserve(uint256 networkId, uint256 amount) external;

    function updateStatus(uint256 networkId, ReserveStatus status) external;

    function getReserve(uint256 networkId) external view returns (NetworkReserve memory);

    function getNetworkCount() external view returns (uint256);
}
