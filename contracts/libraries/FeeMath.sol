// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library FeeMath {

    uint256 internal constant BPS = 10_000;

    function calculate(
        uint256 amount,
        uint256 feeBps
    )
        internal
        pure
        returns (uint256)
    {
        return amount * feeBps / BPS;
    }

    function calculateMultiple(
        uint256 amount,
        uint256 protocolFee,
        uint256 routingFee,
        uint256 partnerFee
    )
        internal
        pure
        returns (uint256)
    {
        uint256 totalFee =
            protocolFee +
            routingFee +
            partnerFee;

        return amount * totalFee / BPS;
    }
}
