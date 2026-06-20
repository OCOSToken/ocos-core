// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IFeeController {
    struct FeeConfig {
        uint256 protocolFeeBps;
        uint256 routingFeeBps;
        uint256 partnerFeeBps;
        uint256 minimumFee;
        uint256 maximumFee;
        bool enabled;
    }

    event FeeConfigUpdated(uint256 indexed networkId);
    event FeeCalculated(uint256 indexed networkId, uint256 amount, uint256 fee);

    function setFeeConfig(
        uint256 networkId,
        uint256 protocolFeeBps,
        uint256 routingFeeBps,
        uint256 partnerFeeBps,
        uint256 minimumFee,
        uint256 maximumFee,
        bool enabled
    ) external;

    function calculateFee(uint256 networkId, uint256 amount)
        external
        view
        returns (uint256 fee);

    function getFeeConfig(uint256 networkId)
        external
        view
        returns (FeeConfig memory);
}
