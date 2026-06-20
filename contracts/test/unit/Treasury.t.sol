// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/Treasury.sol";
import "../mocks/MockERC20.sol";

contract TreasuryTest is Test {
    Treasury treasury;
    MockERC20 token;

    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address receiver = address(0xCAFE);

    function setUp() public {
        treasury = new Treasury(admin);
        token = new MockERC20();

        token.mint(user, 1_000 ether);
        vm.deal(admin, 100 ether);
        vm.deal(user, 100 ether);
    }

    function testDepositERC20() public {
        vm.startPrank(user);
        token.approve(address(treasury), 100 ether);
        treasury.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(address(treasury)), 100 ether);
    }

    function testAdminCanWithdrawERC20() public {
        vm.startPrank(user);
        token.approve(address(treasury), 100 ether);
        treasury.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        vm.prank(admin);
        treasury.withdrawERC20(address(token), receiver, 50 ether);

        assertEq(token.balanceOf(receiver), 50 ether);
    }

    function testNonAdminCannotWithdrawERC20() public {
        vm.prank(user);
        vm.expectRevert();
        treasury.withdrawERC20(address(token), receiver, 50 ether);
    }

    function testReceiveNative() public {
        vm.prank(user);
        payable(address(treasury)).transfer(1 ether);

        assertEq(address(treasury).balance, 1 ether);
    }
}
