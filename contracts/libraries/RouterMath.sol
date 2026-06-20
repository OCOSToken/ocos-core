// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library RouterMath {

    function completionPercent(
        uint256 completed,
        uint256 total
    )
        internal
        pure
        returns (uint256)
    {
        if (total == 0) {
            return 0;
        }

        return completed * 100 / total;
    }
}
