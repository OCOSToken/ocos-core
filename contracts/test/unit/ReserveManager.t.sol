// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/ReserveManager.sol";

contract ReserveManagerTest is Test {
    ReserveManager reserveManager;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    function setUp() public {
        reserveManager = new ReserveManager(admin);
    }

    function testCreateNetworkReserve() public {
        vm.prank(admin);
        reserveManager.createNetworkReserve(1, "Ethereum", 1 ether);

        ReserveManager.NetworkReserve memory reserve = reserveManager.getReserve(1);

        assertEq(reserve.networkId, 1);
        assertEq(reserve.networkName, "Ethereum");
        assertEq(reserve.requiredReserve, 1 ether);
    }

    function testAllocateReserveActivatesNetwork() public {
        vm.prank(admin);
        reserveManager.createNetworkReserve(1, "Ethereum", 1 ether);

        vm.prank(admin);
        reserveManager.allocateReserve(1, 1 ether);

        ReserveManager.NetworkReserve memory reserve = reserveManager.getReserve(1);

        assertEq(uint8(reserve.status), uint8(ReserveManager.ReserveStatus.Active));
    }

    function testNonAdminCannotCreateReserve() public {
        vm.prank(user);
        vm.expectRevert();
        reserveManager.createNetworkReserve(1, "Ethereum", 1 ether);
    }
}
