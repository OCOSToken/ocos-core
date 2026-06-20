// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library Constants {
    uint256 internal constant BPS = 10_000;

    uint256 internal constant DAY = 1 days;

    uint256 internal constant MAX_PROTOCOL_FEE = 1000;

    uint256 internal constant MAX_ROUTING_FEE = 500;

    uint256 internal constant MAX_PARTNER_FEE = 1000;

    uint256 internal constant MAX_SLIPPAGE_BPS = 500;

    uint256 internal constant MAX_DAILY_RISK = 1_000_000 ether;
}
