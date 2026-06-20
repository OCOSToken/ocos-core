// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library AddressUtils {

    function validate(address account) internal pure {
        require(account != address(0), "ZERO_ADDRESS");
    }

    function isValid(address account) internal pure returns(bool) {
        return account != address(0);
    }
}
