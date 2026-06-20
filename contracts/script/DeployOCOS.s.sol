// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "../contracts/core/OCOSRegistry.sol";
import "../contracts/core/AuditLedger.sol";
import "../contracts/core/Treasury.sol";
import "../contracts/core/ReserveManager.sol";
import "../contracts/core/LiquidityVault.sol";
import "../contracts/core/SettlementEngine.sol";
import "../contracts/core/RouterManager.sol";
import "../contracts/core/FeeController.sol";
import "../contracts/core/EmergencyController.sol";

contract DeployOCOS is Script {
    struct Deployment {
        address registry;
        address auditLedger;
        address treasury;
        address reserveManager;
        address liquidityVault;
        address settlementEngine;
        address routerManager;
        address feeController;
        address emergencyController;
    }

    function run() external returns (Deployment memory deployment) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("OCOS_ADMIN");

        require(admin != address(0), "Invalid OCOS_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        OCOSRegistry registry = new OCOSRegistry(admin);
        AuditLedger auditLedger = new AuditLedger(admin);
        Treasury treasury = new Treasury(admin);
        ReserveManager reserveManager = new ReserveManager(admin);
        LiquidityVault liquidityVault = new LiquidityVault(admin);
        SettlementEngine settlementEngine = new SettlementEngine(admin);
        RouterManager routerManager = new RouterManager(admin);
        FeeController feeController = new FeeController(admin);
        EmergencyController emergencyController = new EmergencyController(admin);

        vm.stopBroadcast();

        deployment = Deployment({
            registry: address(registry),
            auditLedger: address(auditLedger),
            treasury: address(treasury),
            reserveManager: address(reserveManager),
            liquidityVault: address(liquidityVault),
            settlementEngine: address(settlementEngine),
            routerManager: address(routerManager),
            feeController: address(feeController),
            emergencyController: address(emergencyController)
        });

        console2.log("OCOS Core deployed");
        console2.log("Registry:", deployment.registry);
        console2.log("AuditLedger:", deployment.auditLedger);
        console2.log("Treasury:", deployment.treasury);
        console2.log("ReserveManager:", deployment.reserveManager);
        console2.log("LiquidityVault:", deployment.liquidityVault);
        console2.log("SettlementEngine:", deployment.settlementEngine);
        console2.log("RouterManager:", deployment.routerManager);
        console2.log("FeeController:", deployment.feeController);
        console2.log("EmergencyController:", deployment.emergencyController);
    }
}
