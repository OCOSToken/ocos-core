// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IOCOSRegistry {
    event ContractAddressSet(
        bytes32 indexed key,
        address indexed oldAddress,
        address indexed newAddress
    );

    function setContract(bytes32 key, address contractAddress) external;

    function getContract(bytes32 key) external view returns (address);
}
