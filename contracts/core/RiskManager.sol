// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract RiskManager is AccessControl, Pausable {
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    bytes32 public constant RISK_OPERATOR_ROLE = keccak256("RISK_OPERATOR_ROLE");

    struct RiskConfig {
        uint256 maxSingleExecution;
        uint256 maxDailyVolume;
        uint256 maxSlippageBps;
        uint256 minLiquidityCoverageBps;
        bool enabled;
    }

    mapping(uint256 => RiskConfig) private networkRiskConfig;
    mapping(uint256 => uint256) public dailyVolume;
    mapping(uint256 => uint256) public lastVolumeReset;

    event RiskConfigUpdated(uint256 indexed networkId);
    event ExecutionRiskChecked(uint256 indexed networkId, uint256 amount, bool approved);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RISK_ADMIN_ROLE, admin);
        _grantRole(RISK_OPERATOR_ROLE, admin);
    }

    function setRiskConfig(
        uint256 networkId,
        uint256 maxSingleExecution,
        uint256 maxDailyVolume,
        uint256 maxSlippageBps,
        uint256 minLiquidityCoverageBps,
        bool enabled
    ) external onlyRole(RISK_ADMIN_ROLE) {
        require(networkId != 0, "Invalid network");
        require(maxSlippageBps <= 10_000, "Invalid slippage");
        require(minLiquidityCoverageBps <= 10_000, "Invalid coverage");

        networkRiskConfig[networkId] = RiskConfig({
            maxSingleExecution: maxSingleExecution,
            maxDailyVolume: maxDailyVolume,
            maxSlippageBps: maxSlippageBps,
            minLiquidityCoverageBps: minLiquidityCoverageBps,
            enabled: enabled
        });

        emit RiskConfigUpdated(networkId);
    }

    function checkExecution(
        uint256 networkId,
        uint256 amount,
        uint256 slippageBps,
        uint256 liquidityCoverageBps
    ) external whenNotPaused onlyRole(RISK_OPERATOR_ROLE) returns (bool) {
        RiskConfig memory config = networkRiskConfig[networkId];

        require(config.enabled, "Risk config disabled");
        require(amount <= config.maxSingleExecution, "Single execution limit");
        require(slippageBps <= config.maxSlippageBps, "Slippage too high");
        require(liquidityCoverageBps >= config.minLiquidityCoverageBps, "Coverage too low");

        if (block.timestamp >= lastVolumeReset[networkId] + 1 days) {
            dailyVolume[networkId] = 0;
            lastVolumeReset[networkId] = block.timestamp;
        }

        require(dailyVolume[networkId] + amount <= config.maxDailyVolume, "Daily volume limit");

        dailyVolume[networkId] += amount;

        emit ExecutionRiskChecked(networkId, amount, true);

        return true;
    }

    function getRiskConfig(uint256 networkId) external view returns (RiskConfig memory) {
        return networkRiskConfig[networkId];
    }

    function pause() external onlyRole(RISK_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(RISK_ADMIN_ROLE) {
        _unpause();
    }
}
