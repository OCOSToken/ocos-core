// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract RouterManager is AccessControl, Pausable {
    bytes32 public constant ROUTER_ADMIN_ROLE = keccak256("ROUTER_ADMIN_ROLE");
    bytes32 public constant ROUTER_OPERATOR_ROLE = keccak256("ROUTER_OPERATOR_ROLE");

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

    mapping(uint256 => Router) private routers;
    uint256[] public routerIds;

    event RouterRegistered(uint256 indexed networkId, string networkName, address routerAddress);
    event RouterAddressUpdated(uint256 indexed networkId, address oldAddress, address newAddress);
    event RouterStatusUpdated(uint256 indexed networkId, RouterStatus oldStatus, RouterStatus newStatus);
    event RouterSyncStarted(uint256 indexed networkId, uint256 timestamp);
    event RouterSyncCompleted(uint256 indexed networkId, uint256 timestamp);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ROUTER_ADMIN_ROLE, admin);
        _grantRole(ROUTER_OPERATOR_ROLE, admin);
    }

    function registerRouter(
        uint256 networkId,
        string calldata networkName,
        address routerAddress
    ) external onlyRole(ROUTER_ADMIN_ROLE) {
        require(networkId != 0, "Invalid network");
        require(bytes(networkName).length > 0, "Invalid name");
        require(routerAddress != address(0), "Invalid router");
        require(routers[networkId].networkId == 0, "Router exists");

        routers[networkId] = Router({
            networkId: networkId,
            networkName: networkName,
            routerAddress: routerAddress,
            status: RouterStatus.Pending,
            syncStartedAt: 0,
            syncCompletedAt: 0,
            updatedAt: block.timestamp
        });

        routerIds.push(networkId);

        emit RouterRegistered(networkId, networkName, routerAddress);
    }

    function updateRouterAddress(
        uint256 networkId,
        address newRouterAddress
    ) external onlyRole(ROUTER_ADMIN_ROLE) {
        Router storage router = routers[networkId];

        require(router.networkId != 0, "Router not found");
        require(newRouterAddress != address(0), "Invalid router");

        address oldAddress = router.routerAddress;
        router.routerAddress = newRouterAddress;
        router.updatedAt = block.timestamp;

        emit RouterAddressUpdated(networkId, oldAddress, newRouterAddress);
    }

    function startSync(uint256 networkId) external whenNotPaused onlyRole(ROUTER_OPERATOR_ROLE) {
        Router storage router = routers[networkId];

        require(router.networkId != 0, "Router not found");
        require(router.status == RouterStatus.Pending || router.status == RouterStatus.Suspended, "Invalid status");

        RouterStatus oldStatus = router.status;
        router.status = RouterStatus.Synchronizing;
        router.syncStartedAt = block.timestamp;
        router.updatedAt = block.timestamp;

        emit RouterStatusUpdated(networkId, oldStatus, RouterStatus.Synchronizing);
        emit RouterSyncStarted(networkId, block.timestamp);
    }

    function completeSync(uint256 networkId) external whenNotPaused onlyRole(ROUTER_OPERATOR_ROLE) {
        Router storage router = routers[networkId];

        require(router.networkId != 0, "Router not found");
        require(router.status == RouterStatus.Synchronizing, "Router not syncing");

        RouterStatus oldStatus = router.status;
        router.status = RouterStatus.Active;
        router.syncCompletedAt = block.timestamp;
        router.updatedAt = block.timestamp;

        emit RouterStatusUpdated(networkId, oldStatus, RouterStatus.Active);
        emit RouterSyncCompleted(networkId, block.timestamp);
    }

    function updateStatus(
        uint256 networkId,
        RouterStatus newStatus
    ) external onlyRole(ROUTER_ADMIN_ROLE) {
        Router storage router = routers[networkId];

        require(router.networkId != 0, "Router not found");

        RouterStatus oldStatus = router.status;
        router.status = newStatus;
        router.updatedAt = block.timestamp;

        emit RouterStatusUpdated(networkId, oldStatus, newStatus);
    }

    function isRouterActive(uint256 networkId) external view returns (bool) {
        return routers[networkId].status == RouterStatus.Active;
    }

    function getRouter(uint256 networkId) external view returns (Router memory) {
        require(routers[networkId].networkId != 0, "Router not found");
        return routers[networkId];
    }

    function getRouterCount() external view returns (uint256) {
        return routerIds.length;
    }

    function pause() external onlyRole(ROUTER_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ROUTER_ADMIN_ROLE) {
        _unpause();
    }
}
