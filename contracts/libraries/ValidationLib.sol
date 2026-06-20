// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library ValidationLib {

    function amount(uint256 value) internal pure {
        require(value > 0, "INVALID_AMOUNT");
    }

    function network(uint256 networkId) internal pure {
        require(networkId > 0, "INVALID_NETWORK");
    }

    function hash(bytes32 hashValue) internal pure {
        require(hashValue != bytes32(0), "INVALID_HASH");
    }

    function notZero(address account) internal pure {
        require(account != address(0), "INVALID_ADDRESS");
    }
}
