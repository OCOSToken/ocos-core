// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract FeeController is AccessControl, Pausable {
    bytes32 public constant FEE_ADMIN_ROLE = keccak256("FEE_ADMIN_ROLE");
    bytes32 public constant FEE_OPERATOR_ROLE = keccak256("FEE_OPERATOR_ROLE");

    uint256 public constant MAX_BPS = 10_000;

    struct FeeConfig {
        uint256 protocolFeeBps;
        uint256 routingFeeBps;
        uint256 partnerFeeBps;
        uint256 minimumFee;
        uint256 maximumFee;
        bool enabled;
    }

    mapping(uint256 => FeeConfig) private networkFees;

    event FeeConfigUpdated(uint256 indexed networkId);
    event FeeCalculated(uint256 indexed networkId, uint256 amount, uint256 fee);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(FEE_ADMIN_ROLE, admin);
        _grantRole(FEE_OPERATOR_ROLE, admin);
    }

    function setFeeConfig(
        uint256 networkId,
        uint256 protocolFeeBps,
        uint256 routingFeeBps,
        uint256 partnerFeeBps,
        uint256 minimumFee,
        uint256 maximumFee,
        bool enabled
    ) external onlyRole(FEE_ADMIN_ROLE) {
        require(networkId != 0, "Invalid network");
        require(protocolFeeBps + routingFeeBps + partnerFeeBps <= MAX_BPS, "Fee too high");

        if (maximumFee > 0) {
            require(maximumFee >= minimumFee, "Invalid fee range");
        }

        networkFees[networkId] = FeeConfig({
            protocolFeeBps: protocolFeeBps,
            routingFeeBps: routingFeeBps,
            partnerFeeBps: partnerFeeBps,
            minimumFee: minimumFee,
            maximumFee: maximumFee,
            enabled: enabled
        });

        emit FeeConfigUpdated(networkId);
    }

    function calculateFee(
        uint256 networkId,
        uint256 amount
    ) public view returns (uint256 fee) {
        FeeConfig memory config = networkFees[networkId];

        require(config.enabled, "Fee disabled");
        require(amount > 0, "Invalid amount");

        uint256 totalBps = config.protocolFeeBps + config.routingFeeBps + config.partnerFeeBps;

        fee = (amount * totalBps) / MAX_BPS;

        if (fee < config.minimumFee) {
            fee = config.minimumFee;
        }

        if (config.maximumFee > 0 && fee > config.maximumFee) {
            fee = config.maximumFee;
        }
    }

    function getFeeConfig(uint256 networkId) external view returns (FeeConfig memory) {
        return networkFees[networkId];
    }

    function pause() external onlyRole(FEE_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(FEE_ADMIN_ROLE) {
        _unpause();
    }
}
