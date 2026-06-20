// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/RouterManager.sol";

contract RouterManagerTest is Test {
    RouterManager routerManager;

    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address router = address(0x1234);

    function setUp() public {
        routerManager = new RouterManager(admin);
    }

    function testRegisterRouter() public {
        vm.prank(admin);
        routerManager.registerRouter(1, "Ethereum", router);

        RouterManager.Router memory r = routerManager.getRouter(1);

        assertEq(r.networkId, 1);
        assertEq(r.networkName, "Ethereum");
        assertEq(r.routerAddress, router);
    }

    function testStartAndCompleteSync() public {
        vm.prank(admin);
        routerManager.registerRouter(1, "Ethereum", router);

        vm.prank(admin);
        routerManager.startSync(1);

        vm.prank(admin);
        routerManager.completeSync(1);

        assertTrue(routerManager.isRouterActive(1));
    }

    function testNonAdminCannotRegisterRouter() public {
        vm.prank(user);
        vm.expectRevert();
        routerManager.registerRouter(1, "Ethereum", router);
    }
}
