// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library RiskMath {

    function utilization(
        uint256 used,
        uint256 total
    )
        internal
        pure
        returns (uint256)
    {
        if (total == 0) {
            return 0;
        }

        return (used * 10000) / total;
    }

    function exceeds(
        uint256 value,
        uint256 limit
    )
        internal
        pure
        returns (bool)
    {
        return value > limit;
    }
}
