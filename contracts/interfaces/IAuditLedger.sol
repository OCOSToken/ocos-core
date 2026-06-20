// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IAuditLedger {
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

    event AuditEntryRecorded(
        uint256 indexed id,
        EntryType indexed entryType,
        bytes32 indexed referenceHash,
        string title,
        string metadataURI,
        address recordedBy,
        uint256 timestamp
    );

    function recordEntry(
        EntryType entryType,
        bytes32 referenceHash,
        string calldata title,
        string calldata metadataURI
    ) external returns (uint256 entryId);

    function getEntry(uint256 entryId) external view returns (AuditEntry memory);

    function totalEntries() external view returns (uint256);
}
