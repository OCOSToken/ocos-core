// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/EmergencyController.sol";

contract MockPausableModule {
    bool public paused;

    function pause() external {
        paused = true;
    }

    function unpause() external {
        paused = false;
    }
}

contract EmergencyControllerTest is Test {
    EmergencyController emergency;
    MockPausableModule moduleA;
    MockPausableModule moduleB;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    function setUp() public {
        emergency = new EmergencyController(admin);
        moduleA = new MockPausableModule();
        moduleB = new MockPausableModule();
    }

    function testAddModule() public {
        vm.prank(admin);
        emergency.addModule(address(moduleA));

        assertTrue(emergency.isModule(address(moduleA)));
    }

    function testActivateGlobalEmergency() public {
        vm.prank(admin);
        emergency.addModule(address(moduleA));

        vm.prank(admin);
        emergency.activateGlobalEmergency();

        assertTrue(emergency.globalEmergency());
        assertTrue(moduleA.paused());
    }

    function testResolveGlobalEmergency() public {
        vm.prank(admin);
        emergency.addModule(address(moduleA));

        vm.prank(admin);
        emergency.activateGlobalEmergency();

        vm.prank(admin);
        emergency.resolveGlobalEmergency();

        assertFalse(emergency.globalEmergency());
        assertFalse(moduleA.paused());
    }

    function testNonGuardianCannotActivateEmergency() public {
        vm.prank(user);
        vm.expectRevert();
        emergency.activateGlobalEmergency();
    }
}
