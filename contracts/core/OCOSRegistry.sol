// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract OCOSRegistry is AccessControl {
    bytes32 public constant REGISTRY_ADMIN_ROLE = keccak256("REGISTRY_ADMIN_ROLE");

    mapping(bytes32 => address) private contractsMap;

    event ContractAddressSet(bytes32 indexed key, address indexed oldAddress, address indexed newAddress);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(REGISTRY_ADMIN_ROLE, admin);
    }

    function setContract(bytes32 key, address contractAddress) external onlyRole(REGISTRY_ADMIN_ROLE) {
        require(key != bytes32(0), "Invalid key");
        require(contractAddress != address(0), "Invalid address");

        address oldAddress = contractsMap[key];
        contractsMap[key] = contractAddress;

        emit ContractAddressSet(key, oldAddress, contractAddress);
    }

    function getContract(bytes32 key) external view returns (address) {
        return contractsMap[key];
    }
}
