// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library ReserveMath {

    function coverage(
        uint256 allocated,
        uint256 requiredReserve
    )
        internal
        pure
        returns (uint256)
    {
        if (requiredReserve == 0) {
            return 0;
        }

        return allocated * 10000 / requiredReserve;
    }

    function fullyCovered(
        uint256 allocated,
        uint256 requiredReserve
    )
        internal
        pure
        returns (bool)
    {
        return allocated >= requiredReserve;
    }
}
