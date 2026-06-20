// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../../core/OCOSRegistry.sol";
import "../../core/AuditLedger.sol";
import "../../core/Treasury.sol";
import "../../core/ReserveManager.sol";
import "../../core/LiquidityVault.sol";
import "../../core/SettlementEngine.sol";
import "../../core/RouterManager.sol";
import "../../core/FeeController.sol";
import "../../core/EmergencyController.sol";

contract OCOSCoreFlowTest is Test {
    OCOSRegistry registry;
    AuditLedger auditLedger;
    Treasury treasury;
    ReserveManager reserveManager;
    LiquidityVault vault;
    SettlementEngine settlementEngine;
    RouterManager routerManager;
    FeeController feeController;
    EmergencyController emergency;

    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address router = address(0x1234);

    function setUp() public {
        registry = new OCOSRegistry(admin);
        auditLedger = new AuditLedger(admin);
        treasury = new Treasury(admin);
        reserveManager = new ReserveManager(admin);
        vault = new LiquidityVault(admin);
        settlementEngine = new SettlementEngine(admin);
        routerManager = new RouterManager(admin);
        feeController = new FeeController(admin);
        emergency = new EmergencyController(admin);
    }

    function testCompleteInfrastructureFlow() public {
        vm.startPrank(admin);

        registry.setContract(keccak256("AUDIT_LEDGER"), address(auditLedger));
        registry.setContract(keccak256("TREASURY"), address(treasury));
        registry.setContract(keccak256("RESERVE_MANAGER"), address(reserveManager));
        registry.setContract(keccak256("LIQUIDITY_VAULT"), address(vault));
        registry.setContract(keccak256("SETTLEMENT_ENGINE"), address(settlementEngine));
        registry.setContract(keccak256("ROUTER_MANAGER"), address(routerManager));
        registry.setContract(keccak256("FEE_CONTROLLER"), address(feeController));
        registry.setContract(keccak256("EMERGENCY_CONTROLLER"), address(emergency));

        routerManager.registerRouter(1, "Ethereum", router);
        routerManager.startSync(1);
        routerManager.completeSync(1);

        reserveManager.createNetworkReserve(1, "Ethereum", 1 ether);
        reserveManager.allocateReserve(1, 1 ether);

        feeController.setFeeConfig(1, 30, 20, 10, 0, 0, true);

        auditLedger.recordEntry(
            AuditLedger.EntryType.System,
            keccak256("system-online"),
            "OCOS Core Initialized",
            "ipfs://ocos-core-init"
        );

        vm.stopPrank();

        assertEq(registry.getContract(keccak256("TREASURY")), address(treasury));
        assertTrue(routerManager.isRouterActive(1));
        assertEq(auditLedger.totalEntries(), 1);
    }

    function testSettlementLifecycle() public {
        vm.prank(user);
        uint256 settlementId = settlementEngine.createSettlement(
            1,
            56,
            address(0),
            1 ether,
            keccak256("destination"),
            keccak256("created")
        );

        vm.prank(admin);
        settlementEngine.updateSettlementStatus(
            settlementId,
            SettlementEngine.SettlementStatus.Executing,
            keccak256("executing")
        );

        vm.prank(admin);
        settlementEngine.updateSettlementStatus(
            settlementId,
            SettlementEngine.SettlementStatus.Completed,
            keccak256("completed")
        );

        SettlementEngine.SettlementRequest memory s =
            settlementEngine.getSettlement(settlementId);

        assertEq(uint8(s.status), uint8(SettlementEngine.SettlementStatus.Completed));
    }
}
