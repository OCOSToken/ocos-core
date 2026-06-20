// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/OCOSRegistry.sol";

contract OCOSRegistryTest is Test {
    OCOSRegistry registry;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    bytes32 constant TREASURY_KEY = keccak256("TREASURY");

    function setUp() public {
        registry = new OCOSRegistry(admin);
    }

    function testAdminCanSetContract() public {
        vm.prank(admin);
        registry.setContract(TREASURY_KEY, address(0x1234));

        assertEq(registry.getContract(TREASURY_KEY), address(0x1234));
    }

    function testNonAdminCannotSetContract() public {
        vm.prank(user);
        vm.expectRevert();
        registry.setContract(TREASURY_KEY, address(0x1234));
    }

    function testCannotSetZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert("Invalid address");
        registry.setContract(TREASURY_KEY, address(0));
    }
}
