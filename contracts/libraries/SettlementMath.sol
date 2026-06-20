// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library SettlementMath {

    function isFinalized(uint8 status)
        internal
        pure
        returns (bool)
    {
        return (
            status == 2 ||
            status == 3 ||
            status == 4
        );
    }
}
