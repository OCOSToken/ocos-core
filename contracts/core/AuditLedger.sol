// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract AuditLedger is AccessControl, Pausable {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    enum EntryType {
        System,
        Reserve,
        Settlement,
        Router,
        Security,
        Governance
    }

    struct AuditEntry {
        uint256 id;
        EntryType entryType;
        bytes32 referenceHash;
        string title;
        string metadataURI;
        address recordedBy;
        uint256 timestamp;
    }

    uint256 public totalEntries;

    mapping(uint256 => AuditEntry) private entries;

    event AuditEntryRecorded(
        uint256 indexed id,
        EntryType indexed entryType,
        bytes32 indexed referenceHash,
        string title,
        string metadataURI,
        address recordedBy,
        uint256 timestamp
    );

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(AUDITOR_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
    }

    function recordEntry(
        EntryType entryType,
        bytes32 referenceHash,
        string calldata title,
        string calldata metadataURI
    ) external whenNotPaused onlyRole(AUDITOR_ROLE) returns (uint256 entryId) {
        require(referenceHash != bytes32(0), "Invalid reference hash");
        require(bytes(title).length > 0, "Empty title");

        entryId = ++totalEntries;

        entries[entryId] = AuditEntry({
            id: entryId,
            entryType: entryType,
            referenceHash: referenceHash,
            title: title,
            metadataURI: metadataURI,
            recordedBy: msg.sender,
            timestamp: block.timestamp
        });

        emit AuditEntryRecorded(
            entryId,
            entryType,
            referenceHash,
            title,
            metadataURI,
            msg.sender,
            block.timestamp
        );
    }

    function getEntry(uint256 entryId) external view returns (AuditEntry memory) {
        require(entryId > 0 && entryId <= totalEntries, "Invalid entry");
        return entries[entryId];
    }

    function pause() external onlyRole(OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
