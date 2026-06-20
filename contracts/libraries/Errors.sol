// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

library Errors {
    error Unauthorized();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidNetwork();
    error InvalidRouter();
    error InvalidReserve();
    error InvalidSettlement();

    error InsufficientBalance();
    error InsufficientLiquidity();
    error InsufficientReserve();

    error RouterNotFound();
    error RouterInactive();

    error SettlementNotFound();
    error SettlementFinalized();

    error FeeDisabled();
    error RiskViolation();

    error EmergencyModeActive();

    error AlreadyExists();
    error NotFound();

    error InvalidStatusTransition();
}
