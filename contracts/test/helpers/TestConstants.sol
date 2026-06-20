// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library TestConstants {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant OPERATOR = address(0xB0B);
    address internal constant USER = address(0xCAFE);
    address internal constant RECEIVER = address(0xDAD);

    uint256 internal constant ETHEREUM_ID = 1;
    uint256 internal constant BNB_ID = 56;
    uint256 internal constant POLYGON_ID = 137;

    uint256 internal constant ONE_ETH = 1 ether;
    uint256 internal constant TEN_ETH = 10 ether;

    bytes32 internal constant REF_HASH = keccak256("OCOS_REFERENCE_HASH");
    bytes32 internal constant DEST_HASH = keccak256("DESTINATION_ACCOUNT");
}
