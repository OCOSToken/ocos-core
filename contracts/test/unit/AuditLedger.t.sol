// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../core/AuditLedger.sol";

contract AuditLedgerTest is Test {
    AuditLedger ledger;

    address admin = address(0xA11CE);
    address user = address(0xB0B);

    bytes32 refHash = keccak256("audit-proof");

    function setUp() public {
        ledger = new AuditLedger(admin);
    }

    function testAuditorCanRecordEntry() public {
        vm.prank(admin);
        uint256 id = ledger.recordEntry(
            AuditLedger.EntryType.Security,
            refHash,
            "Security Review",
            "ipfs://audit-metadata"
        );

        assertEq(id, 1);
        assertEq(ledger.totalEntries(), 1);
    }

    function testNonAuditorCannotRecordEntry() public {
        vm.prank(user);
        vm.expectRevert();
        ledger.recordEntry(
            AuditLedger.EntryType.Security,
            refHash,
            "Security Review",
            "ipfs://audit-metadata"
        );
    }

    function testCannotRecordEmptyHash() public {
        vm.prank(admin);
        vm.expectRevert("Invalid reference hash");
        ledger.recordEntry(
            AuditLedger.EntryType.Security,
            bytes32(0),
            "Security Review",
            "ipfs://audit-metadata"
        );
    }
}
