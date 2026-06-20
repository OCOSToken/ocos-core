// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IRouterManager {
    enum RouterStatus {
        Pending,
        Synchronizing,
        Active,
        Suspended,
        Disabled
    }

    struct Router {
        uint256 networkId;
        string networkName;
        address routerAddress;
        RouterStatus status;
        uint256 syncStartedAt;
        uint256 syncCompletedAt;
        uint256 updatedAt;
    }

    event RouterRegistered(
        uint256 indexed networkId,
        string networkName,
        address routerAddress
    );

    event RouterAddressUpdated(
        uint256 indexed networkId,
        address oldAddress,
        address newAddress
    );

    event RouterStatusUpdated(
        uint256 indexed networkId,
        RouterStatus oldStatus,
        RouterStatus newStatus
    );

    event RouterSyncStarted(uint256 indexed networkId, uint256 timestamp);
    event RouterSyncCompleted(uint256 indexed networkId, uint256 timestamp);

    function registerRouter(
        uint256 networkId,
        string calldata networkName,
        address routerAddress
    ) external;

    function updateRouterAddress(
        uint256 networkId,
        address newRouterAddress
    ) external;

    function startSync(uint256 networkId) external;

    function completeSync(uint256 networkId) external;

    function updateStatus(uint256 networkId, RouterStatus newStatus) external;

    function isRouterActive(uint256 networkId) external view returns (bool);

    function getRouter(uint256 networkId) external view returns (Router memory);

    function getRouterCount() external view returns (uint256);
}
