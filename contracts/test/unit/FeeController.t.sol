// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/FeeController.sol";

contract FeeControllerTest is Test {
    FeeController feeController;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    function setUp() public {
        feeController = new FeeController(admin);
    }

    function testSetFeeConfigAndCalculateFee() public {
        vm.prank(admin);
        feeController.setFeeConfig(
            1,
            30,
            20,
            10,
            0,
            0,
            true
        );

        uint256 fee = feeController.calculateFee(1, 10_000 ether);

        assertEq(fee, 60 ether);
    }

    function testMinimumFeeApplied() public {
        vm.prank(admin);
        feeController.setFeeConfig(
            1,
            1,
            0,
            0,
            1 ether,
            0,
            true
        );

        uint256 fee = feeController.calculateFee(1, 100 ether);

        assertEq(fee, 1 ether);
    }

    function testMaximumFeeApplied() public {
        vm.prank(admin);
        feeController.setFeeConfig(
            1,
            1000,
            0,
            0,
            0,
            5 ether,
            true
        );

        uint256 fee = feeController.calculateFee(1, 100 ether);

        assertEq(fee, 5 ether);
    }

    function testNonAdminCannotSetFee() public {
        vm.prank(user);
        vm.expectRevert();
        feeController.setFeeConfig(
            1,
            30,
            20,
            10,
            0,
            0,
            true
        );
    }
}
