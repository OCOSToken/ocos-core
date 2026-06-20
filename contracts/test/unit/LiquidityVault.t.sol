// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/LiquidityVault.sol";
import "../mocks/MockERC20.sol";

contract LiquidityVaultTest is Test {
    LiquidityVault vault;
    MockERC20 token;

    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address receiver = address(0xCAFE);

    function setUp() public {
        vault = new LiquidityVault(admin);
        token = new MockERC20();

        token.mint(user, 1_000 ether);
        vm.deal(user, 100 ether);
    }

    function testDepositERC20() public {
        vm.startPrank(user);
        token.approve(address(vault), 100 ether);
        vault.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(address(vault)), 100 ether);
    }

    function testAllocateLiquidity() public {
        vm.startPrank(user);
        token.approve(address(vault), 100 ether);
        vault.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        vm.prank(admin);
        vault.allocate(address(token), receiver, 20 ether);

        assertEq(vault.allocatedLiquidity(address(token)), 20 ether);
    }

    function testReleaseLiquidity() public {
        vm.startPrank(user);
        token.approve(address(vault), 100 ether);
        vault.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        vm.prank(admin);
        vault.allocate(address(token), receiver, 20 ether);

        vm.prank(admin);
        vault.release(address(token), 10 ether);

        assertEq(vault.allocatedLiquidity(address(token)), 10 ether);
    }

    function testAdminCanWithdrawFreeLiquidity() public {
        vm.startPrank(user);
        token.approve(address(vault), 100 ether);
        vault.depositERC20(address(token), 100 ether);
        vm.stopPrank();

        vm.prank(admin);
        vault.withdraw(address(token), payable(receiver), 50 ether);

        assertEq(token.balanceOf(receiver), 50 ether);
    }
}
