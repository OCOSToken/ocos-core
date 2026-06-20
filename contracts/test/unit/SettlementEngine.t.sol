// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/SettlementEngine.sol";

contract SettlementEngineTest is Test {
    SettlementEngine engine;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    bytes32 destHash = keccak256("destination");
    bytes32 refHash = keccak256("reference");

    function setUp() public {
        engine = new SettlementEngine(admin);
    }

    function testCreateSettlement() public {
        vm.prank(user);
        uint256 id = engine.createSettlement(
            1,
            56,
            address(0),
            1 ether,
            destHash,
            refHash
        );

        assertEq(id, 1);
        assertEq(engine.totalSettlements(), 1);
    }

    function testOperatorCanUpdateStatus() public {
        vm.prank(user);
        uint256 id = engine.createSettlement(
            1,
            56,
            address(0),
            1 ether,
            destHash,
            refHash
        );

        vm.prank(admin);
        engine.updateSettlementStatus(
            id,
            SettlementEngine.SettlementStatus.Completed,
            keccak256("completed")
        );

        SettlementEngine.SettlementRequest memory s = engine.getSettlement(id);

        assertEq(uint8(s.status), uint8(SettlementEngine.SettlementStatus.Completed));
    }

    function testCannotUpdateFinalizedSettlement() public {
        vm.prank(user);
        uint256 id = engine.createSettlement(
            1,
            56,
            address(0),
            1 ether,
            destHash,
            refHash
        );

        vm.prank(admin);
        engine.updateSettlementStatus(
            id,
            SettlementEngine.SettlementStatus.Completed,
            keccak256("completed")
        );

        vm.prank(admin);
        vm.expectRevert("Already finalized");
        engine.updateSettlementStatus(
            id,
            SettlementEngine.SettlementStatus.Failed,
            keccak256("failed")
        );
    }
}
