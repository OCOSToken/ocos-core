// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ReserveManager is AccessControl, Pausable {
    bytes32 public constant RESERVE_ADMIN_ROLE = keccak256("RESERVE_ADMIN_ROLE");
    bytes32 public constant RESERVE_OPERATOR_ROLE = keccak256("RESERVE_OPERATOR_ROLE");

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

    mapping(uint256 => NetworkReserve) private reserves;

    uint256[] public networkIds;

    event NetworkReserveCreated(uint256 indexed networkId, string networkName, uint256 requiredReserve);
    event ReserveAllocated(uint256 indexed networkId, uint256 amount, ReserveStatus status);
    event ReserveStatusUpdated(uint256 indexed networkId, ReserveStatus status);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RESERVE_ADMIN_ROLE, admin);
        _grantRole(RESERVE_OPERATOR_ROLE, admin);
    }

    function createNetworkReserve(
        uint256 networkId,
        string calldata networkName,
        uint256 requiredReserve
    ) external onlyRole(RESERVE_ADMIN_ROLE) {
        require(networkId != 0, "Invalid network id");
        require(bytes(networkName).length > 0, "Invalid network name");
        require(requiredReserve > 0, "Invalid reserve");
        require(reserves[networkId].networkId == 0, "Already exists");

        reserves[networkId] = NetworkReserve({
            networkId: networkId,
            networkName: networkName,
            requiredReserve: requiredReserve,
            allocatedReserve: 0,
            status: ReserveStatus.Pending,
            updatedAt: block.timestamp
        });

        networkIds.push(networkId);

        emit NetworkReserveCreated(networkId, networkName, requiredReserve);
    }

    function allocateReserve(
        uint256 networkId,
        uint256 amount
    ) external whenNotPaused onlyRole(RESERVE_OPERATOR_ROLE) {
        NetworkReserve storage reserve = reserves[networkId];

        require(reserve.networkId != 0, "Network not found");
        require(amount > 0, "Invalid amount");

        reserve.allocatedReserve += amount;

        if (reserve.allocatedReserve >= reserve.requiredReserve) {
            reserve.status = ReserveStatus.Active;
        }

        reserve.updatedAt = block.timestamp;

        emit ReserveAllocated(networkId, amount, reserve.status);
    }

    function updateStatus(
        uint256 networkId,
        ReserveStatus status
    ) external onlyRole(RESERVE_ADMIN_ROLE) {
        NetworkReserve storage reserve = reserves[networkId];

        require(reserve.networkId != 0, "Network not found");

        reserve.status = status;
        reserve.updatedAt = block.timestamp;

        emit ReserveStatusUpdated(networkId, status);
    }

    function getReserve(uint256 networkId) external view returns (NetworkReserve memory) {
        require(reserves[networkId].networkId != 0, "Network not found");
        return reserves[networkId];
    }

    function getNetworkCount() external view returns (uint256) {
        return networkIds.length;
    }

    function pause() external onlyRole(RESERVE_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(RESERVE_ADMIN_ROLE) {
        _unpause();
    }
}
